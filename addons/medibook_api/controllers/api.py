import hashlib
import json
import uuid

import requests

from odoo import fields
from datetime import datetime, timedelta

from odoo import http
from odoo.exceptions import AccessDenied, AccessError, ValidationError
from odoo.http import request, root


class MediBookApi(http.Controller):

    def _json(self, data, status=200, cookies=None):
        return request.make_json_response({"data": data}, status=status, cookies=cookies)

    def _error(self, code, status, message=None):
        body={"code":code}
        if message:
            body["message"]=message
        return request.make_json_response(body, status=status)

    def _body(self):
        raw=request.httprequest.get_data(cache=True, as_text=True)
        if not raw:
            return {}
        try:
            value=json.loads(raw)
        except (TypeError, ValueError):
            raise ValidationError("Invalid JSON body.")
        return value if isinstance(value, dict) else {}

    def _session_user(self):
        auth=request.httprequest.headers.get("Authorization","")
        if auth.lower().startswith("bearer "):
            sid=auth[7:].strip()
            if sid:
                session=root.session_store.get(sid)
                if session and session.get("uid") and session.get("db")==request.db:
                    request.update_env(user=int(session["uid"]))
                    request.session=session
                    return request.env.user
        if request.session.uid and request.session.uid != request.env.ref("base.public_user").id:
            return request.env.user
        return request.env["res.users"]

    def _require_user(self):
        user=self._session_user()
        if not user or not user.exists() or user._is_public():
            raise AccessDenied()
        return user

    def _org(self, user):
        if user.medibook_organization_id:
            return user.medibook_organization_id
        patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
        if patient:
            return patient.organization_id
        practitioner=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
        return practitioner.organization_id if practitioner else False

    def _permissions(self, user):
        mapping=[
          ("viewOwnAppointments","viewOwnAppointments"),
          ("viewAnyAppointment","viewAnyAppointment"),
          ("bookAppointment","bookAppointment"),
          ("cancelOwnAppointment","cancelOwnAppointment"),
          ("cancelAnyAppointment","cancelAnyAppointment"),
          ("viewOwnMedicalRecord","viewOwnMedicalRecord"),
          ("viewAnyMedicalRecord","viewAnyMedicalRecord"),
          ("writePrescription","writePrescription"),
          ("joinTelehealth","joinTelehealth"),
          ("hostTelehealth","hostTelehealth"),
          ("manageClinicStaff","manageClinicStaff"),
          ("viewBilling","viewBilling"),
          ("processPayment","processPayment"),
          ("manageOrganization","manageOrganization"),
        ]
        out=[]
        groups=user.group_ids
        if groups.filtered(lambda g:g.id==request.env.ref("medibook_base.group_medibook_patient").id):
            out += ["viewOwnAppointments","bookAppointment","cancelOwnAppointment","viewOwnMedicalRecord","joinTelehealth"]
        if groups.filtered(lambda g:g.id==request.env.ref("medibook_base.group_medibook_doctor").id):
            out += ["viewOwnAppointments","viewAnyAppointment","viewAnyMedicalRecord","writePrescription","joinTelehealth","hostTelehealth"]
        if groups.filtered(lambda g:g.id==request.env.ref("medibook_base.group_medibook_receptionist").id):
            out += ["viewAnyAppointment"]
        if groups.filtered(lambda g:g.id in {
            request.env.ref("medibook_base.group_medibook_clinic_admin").id,
            request.env.ref("medibook_base.group_medibook_org_admin").id,
            request.env.ref("medibook_base.group_medibook_super_admin").id,
        }):
            out += ["viewAnyAppointment","manageClinicStaff","viewBilling"]
        if groups.filtered(lambda g:g.id in {
            request.env.ref("medibook_base.group_medibook_org_admin").id,
            request.env.ref("medibook_base.group_medibook_super_admin").id,
        }):
            out += ["processPayment","manageOrganization","viewAnyMedicalRecord"]
        return sorted(set(out))

    def _roles(self,user):
        r=[]
        refs={
          "patient":"medibook_base.group_medibook_patient",
          "doctor":"medibook_base.group_medibook_doctor",
          "receptionist":"medibook_base.group_medibook_receptionist",
          "clinicAdmin":"medibook_base.group_medibook_clinic_admin",
          "orgAdmin":"medibook_base.group_medibook_org_admin",
          "superAdmin":"medibook_base.group_medibook_super_admin",
        }
        for name,xmlid in refs.items():
            if user.has_group(xmlid): r.append(name)
        return r

    def _user_json(self,user):
        org=self._org(user)
        clinics=user.medibook_clinic_ids
        patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
        practitioner=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
        return {
          "id":str(user.id),
          "display_name":user.name,
          "email":user.login,
          "roles":self._roles(user),
          "permissions":self._permissions(user),
          "organization_id":str(org.id) if org else "0",
          "clinic_ids":[str(x.id) for x in clinics],
          "avatar_url":patient.avatar_url if patient else (practitioner.avatar_url if practitioner else None),
          "locale":patient.preferred_locale if patient else "ar",
        }

    @http.route("/auth/login",type="http",auth="none",methods=["POST"],csrf=False)
    def login(self,**kw):
        try:
            body=self._body()
            login=(body.get("email") or "").strip().lower()
            password=body.get("password") or ""
            if not login or not password:
                return self._error("invalid_credentials",400)
            request.session.authenticate(request.env,{"login":login,"password":password,"type":"password"})
            user=request.env.user
            now=datetime.utcnow()
            return self._json({
              "access_token":request.session.sid,
              "refresh_token":None,
              "access_expires_at":(now+timedelta(days=7)).isoformat()+"Z",
              "refresh_expires_at":None,
              "session_id":request.session.sid,
              "user":self._user_json(user),
            },cookies={"session_id":request.session.sid})
        except AccessDenied:
            return self._error("unauthorized",401)

    @http.route("/auth/register",type="http",auth="none",methods=["POST"],csrf=False)
    def register(self,**kw):
        try:
            body=self._body()
            login=(body.get("email") or "").strip().lower()
            password=body.get("password") or ""
            name=(body.get("display_name") or "").strip()
            if not login or len(password)<8 or not name:
                return self._error("invalid_registration",422)
            Users=request.env["res.users"].sudo()
            if Users.search_count([("login","=",login)]):
                return self._error("email_already_in_use",409)
            company=request.env.company
            Org=request.env["medibook.organization"].sudo()
            org=Org.search([("company_id","=",company.id)],limit=1)
            if not org:
                org=Org.create({"name":company.name,"code":"ORG-%s"%company.id,"company_id":company.id})
            partner=request.env["res.partner"].sudo().create({"name":name,"email":login})
            portal=request.env.ref("base.group_portal")
            patient_group=request.env.ref("medibook_base.group_medibook_patient")
            user=Users.create({
              "name":name,"login":login,"password":password,"partner_id":partner.id,
              "company_id":company.id,"company_ids":[(6,0,[company.id])],
              "group_ids":[(6,0,[portal.id,patient_group.id])],
              "medibook_organization_id":org.id,
            })
            request.session.authenticate(request.env,{"login":login,"password":password,"type":"password"})
            patient=request.env["medibook.patient"].sudo().sudo().create({
              "name":name,"user_id":user.id,"organization_id":org.id,"preferred_locale":"ar",
            })
            user.sudo().write({"medibook_organization_id":org.id})
            now=datetime.utcnow()
            return self._json({
              "access_token":request.session.sid,"refresh_token":None,
              "access_expires_at":(now+timedelta(days=7)).isoformat()+"Z","refresh_expires_at":None,
              "session_id":request.session.sid,"user":self._user_json(user),
            },cookies={"session_id":request.session.sid})
        except ValidationError as e:
            return self._error("invalid_registration",422,str(e))
        except AccessDenied:
            return self._error("registration_failed",400)

    @http.route("/auth/me",type="http",auth="none",methods=["GET"],csrf=False)
    def me(self,**kw):
        try:
            user=self._require_user()
            return self._json(self._user_json(user))
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/auth/logout",type="http",auth="none",methods=["POST"],csrf=False)
    def logout(self,**kw):
        self._session_user()
        request.session.logout(keep_db=True)
        return self._json({})

    @http.route("/appointments",type="http",auth="none",methods=["GET","POST"],csrf=False)
    def appointments(self,**kw):
        try:
            user=self._require_user()
            Model=request.env["medibook.appointment"].sudo()
            if request.httprequest.method=="GET":
                domain=[]
                patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
                if user.has_group("medibook_base.group_medibook_patient"):
                    domain.append(("patient_id","=",patient.id))
                elif user.has_group("medibook_base.group_medibook_doctor"):
                    doctor=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
                    domain.append(("doctor_id","=",doctor.id))
                else:
                    org=self._org(user)
                    domain.append(("organization_id","=",org.id))
                body=self._body() if request.httprequest.data else {}
                recs=Model.search(domain,order="starts_at asc")
                return self._json([self._appointment_json(x) for x in recs])
            body=self._body()
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not patient: return self._error("patient_profile_required",403)
            if not user.has_group("medibook_base.group_medibook_patient"): return self._error("forbidden",403)
            existing=Model.search([("idempotency_key","=",idempotency_key)],limit=1) if idempotency_key else Model.browse()
            if existing:
                return self._json(self._appointment_json(existing))
            vals={
              "name":body.get("id") or str(uuid.uuid4()),
              "idempotency_key":idempotency_key,
              "clinic_id":int(body["clinic_id"]),"patient_id":patient.id,"doctor_id":int(body["doctor_id"]),
              "service_id":int(body["service_id"]),"starts_at":body["starts_at"],
              "duration_minutes":int(body.get("duration_minutes") or request.env["medibook.medical.service"].sudo().browse(int(body["service_id"])).duration_minutes),
              "is_telehealth":bool(body.get("is_telehealth",False)),"notes":body.get("notes"),
            }
            rec=Model.create(vals)
            return self._json(self._appointment_json(rec),201)
        except AccessDenied:return self._error("unauthorized",401)
        except AccessError:return self._error("forbidden",403)
        except (ValidationError,KeyError,ValueError) as e:return self._error("validation_error",422,str(e))

    def _appointment_json(self,a):
        return {
          "id":str(a.id),"clinic_id":str(a.clinic_id.id),"clinic_name":a.clinic_id.name,
          "patient_id":str(a.patient_id.id),"doctor_id":str(a.doctor_id.id),"doctor_name":a.doctor_id.name,
          "doctor_avatar_url":a.doctor_id.avatar_url,"service_id":str(a.service_id.id),"service_name":a.service_id.name,
          "starts_at":a.starts_at.isoformat()+"Z" if a.starts_at else None,
          "duration_minutes":a.duration_minutes,"status":a.status,"is_telehealth":a.is_telehealth,
          "room_label":a.room_label,"cancellation_reason":a.cancellation_reason,"cancelled_at":a.cancelled_at.isoformat()+"Z" if a.cancelled_at else None,
          "notes":a.notes,"created_at":a.create_date.isoformat()+"Z","updated_at":a.write_date.isoformat()+"Z","version":a.version,
        }


    @http.route("/clinics",type="http",auth="none",methods=["GET"],csrf=False)
    def clinics(self,**kw):
        try:
            user=self._require_user(); org=self._org(user)
            recs=request.env["medibook.clinic"].sudo().search([("organization_id","=",org.id),("active","=",True)])
            return self._json([{"id":str(x.id),"name":x.name,"code":x.code,"organization_id":str(x.organization_id.id),"timezone":x.timezone} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/medical-services",type="http",auth="none",methods=["GET"],csrf=False)
    def services(self,**kw):
        try:
            user=self._require_user(); org=self._org(user)
            recs=request.env["medibook.medical.service"].sudo().search([("organization_id","=",org.id),("active","=",True)])
            return self._json([{"id":str(x.id),"name":x.name,"code":x.code,"duration_minutes":x.duration_minutes,"price":x.price,"currency":x.currency_id.name} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/doctors",type="http",auth="none",methods=["GET"],csrf=False)
    def doctors(self,**kw):
        try:
            user=self._require_user(); org=self._org(user)
            recs=request.env["medibook.practitioner"].sudo().search([("organization_id","=",org.id),("active","=",True)])
            return self._json([{"id":str(x.id),"name":x.name,"specialty":x.specialty,"avatar_url":x.avatar_url,"clinic_ids":[str(c.id) for c in x.clinic_ids]} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/appointments/availability",type="http",auth="none",methods=["GET"],csrf=False)
    def availability(self,**kw):
        try:
            user=self._require_user()
            doctor_id=request.httprequest.args.get("doctor_id")
            clinic_id=request.httprequest.args.get("clinic_id")
            date=request.httprequest.args.get("date")
            if not doctor_id or not clinic_id or not date:return self._error("validation_error",422)
            day=datetime.fromisoformat(date).date()
            weekday=day.weekday()
            schedules=request.env["medibook.schedule"].sudo().search([("doctor_id","=",int(doctor_id)),("clinic_id","=",int(clinic_id)),("weekday","=",weekday),("active","=",True)])
            slots=[]
            for s in schedules:
                start_min=int(s.start_time*60); end_min=int(s.end_time*60)
                for minute in range(start_min,end_min,max(1,request.env["medibook.medical.service"].sudo().browse(int(request.httprequest.args.get("service_id") or 0)).duration_minutes or 30)):
                    hh,mm=divmod(minute,60)
                    starts=f"{day.isoformat()}T{hh:02d}:{mm:02d}:00"
                    end=day.isoformat()+f"T{(minute+30)//60:02d}:{(minute+30)%60:02d}:00"
                    if not request.env["medibook.appointment"].sudo().search_count([("doctor_id","=",int(doctor_id)),("status","in",["scheduled","checked_in","in_consultation"]),("starts_at","<",end)]):
                        slots.append({"starts_at":starts+"Z","duration_minutes":30})
            return self._json(slots)
        except (AccessDenied,AccessError):return self._error("forbidden",403)

    @http.route("/appointments/<int:appointment_id>",type="http",auth="none",methods=["GET","PATCH"],csrf=False)
    def appointment(self,appointment_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.appointment"].sudo().browse(appointment_id)
            if not rec.exists():return self._error("not_found",404)
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            allowed=(patient and rec.patient_id.id==patient.id) or user.has_group("medibook_base.group_medibook_doctor") or user.has_group("medibook_base.group_medibook_receptionist")
            if not allowed:return self._error("forbidden",403)
            if request.httprequest.method=="GET":return self._json(self._appointment_json(rec))
            body=self._body()
            if_match=request.httprequest.headers.get("If-Match")
            if if_match and if_match.strip('"') != str(rec.version):return self._error("conflict",409)
            if "starts_at" in body:rec.write({"starts_at":body["starts_at"]})
            if "notes" in body:rec.write({"notes":body["notes"]})
            return self._json(self._appointment_json(rec))
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,AccessError) as e:return self._error("validation_error",422,str(e))

    @http.route("/appointments/<int:appointment_id>/cancel",type="http",auth="none",methods=["POST"],csrf=False)
    def cancel_appointment(self,appointment_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.appointment"].sudo().browse(appointment_id)
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not rec.exists():return self._error("not_found",404)
            if not patient or rec.patient_id.id!=patient.id:
                if not user.has_group("medibook_base.group_medibook_receptionist"):return self._error("forbidden",403)
            if rec.status in ("completed","cancelled","no_show"):return self._error("invalid_state",409)
            body=self._body(); rec.write({"status":"cancelled","cancellation_reason":body.get("reason"),"cancelled_at":fields.Datetime.now()})
            return self._json(self._appointment_json(rec))
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/appointments/<int:appointment_id>/reschedule",type="http",auth="none",methods=["POST"],csrf=False)
    def reschedule(self,appointment_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.appointment"].sudo().browse(appointment_id); body=self._body()
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not rec.exists():return self._error("not_found",404)
            if not patient or rec.patient_id.id!=patient.id:return self._error("forbidden",403)
            rec.write({"starts_at":body["starts_at"],"status":"scheduled"})
            return self._json(self._appointment_json(rec))
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,KeyError) as e:return self._error("validation_error",422,str(e))

    @http.route("/patients",type="http",auth="none",methods=["GET"],csrf=False)
    def patients(self,**kw):
        try:
            user=self._require_user(); Patient=request.env["medibook.patient"].sudo(); org=self._org(user)
            if user.has_group("medibook_base.group_medibook_doctor"):
                doctor=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
                ids=request.env["medibook.appointment"].sudo().search([("doctor_id","=",doctor.id)]).mapped("patient_id").ids
                recs=Patient.search([("id","in",ids)])
            elif user.has_group("medibook_base.group_medibook_receptionist") or user.has_group("medibook_base.group_medibook_clinic_admin"):
                recs=Patient.search([("organization_id","=",org.id)])
            else:return self._error("forbidden",403)
            return self._json([{"id":str(x.id),"display_name":x.name,"organization_id":str(x.organization_id.id),"avatar_url":x.avatar_url,"preferred_locale":x.preferred_locale,"date_of_birth":x.date_of_birth.isoformat() if x.date_of_birth else None} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/patients/<int:patient_id>",type="http",auth="none",methods=["GET"],csrf=False)
    def patient(self,patient_id,**kw):
        try:
            user=self._require_user(); p=request.env["medibook.patient"].sudo().browse(patient_id)
            if not p.exists():return self._error("not_found",404)
            own=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id),("id","=",patient_id)],limit=1)
            if not own and not user.has_group("medibook_base.group_medibook_doctor") and not user.has_group("medibook_base.group_medibook_receptionist"):return self._error("not_found",404)
            return self._json({"id":str(p.id),"display_name":p.name,"organization_id":str(p.organization_id.id),"avatar_url":p.avatar_url,"preferred_locale":p.preferred_locale,"date_of_birth":p.date_of_birth.isoformat() if p.date_of_birth else None})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/patients/<int:patient_id>/medical-record",type="http",auth="none",methods=["GET"],csrf=False)
    def patient_record(self,patient_id,**kw):
        return self.medical_records(patient_id=patient_id)

    @http.route("/medical-records",type="http",auth="none",methods=["GET"],csrf=False)
    def medical_records(self,patient_id=None,**kw):
        try:
            user=self._require_user()
            patient=request.env["medibook.patient"].sudo().browse(int(patient_id)) if patient_id else request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not patient.exists():return self._error("not_found",404)
            own=patient.user_id.id==user.id
            if not own and not user.has_group("medibook_base.group_medibook_doctor"):return self._error("not_found",404)
            recs=request.env["medibook.medical.record"].sudo().search([("patient_id","=",patient.id)])
            return self._json([{"id":str(x.id),"patient_id":str(x.patient_id.id),"record_type":x.record_type,"title":x.title,"content":x.content,"recorded_at":x.recorded_at.isoformat()+"Z","signed_at":x.signed_at.isoformat()+"Z" if x.signed_at else None} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/consultations",type="http",auth="none",methods=["GET","POST"],csrf=False)
    def consultations(self,**kw):
        try:
            user=self._require_user(); Model=request.env["medibook.consultation"].sudo()
            if request.httprequest.method=="GET":
                domain=[]
                if user.has_group("medibook_base.group_medibook_doctor"):
                    doctor=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1); domain=[("doctor_id","=",doctor.id)]
                else:
                    patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1); domain=[("patient_id","=",patient.id)]
                return self._json([self._consultation_json(x) for x in Model.search(domain)])
            body=self._body(); appt=Model.env["medibook.appointment"].browse(int(body["appointment_id"]))
            if not user.has_group("medibook_base.group_medibook_doctor"):return self._error("forbidden",403)
            rec=Model.create({"name":body.get("name") or ("CONS-"+str(appt.id)),"appointment_id":appt.id})
            return self._json(self._consultation_json(rec),201)
        except AccessDenied:return self._error("unauthorized",401)

    def _consultation_json(self,c):
        return {"id":str(c.id),"appointment_id":str(c.appointment_id.id),"patient_id":str(c.patient_id.id),"doctor_id":str(c.doctor_id.id),"state":c.state,"notes":c.notes,"diagnosis":c.diagnosis,"started_at":c.started_at.isoformat()+"Z" if c.started_at else None,"signed_at":c.signed_at.isoformat()+"Z" if c.signed_at else None}

    @http.route("/prescriptions",type="http",auth="none",methods=["GET","POST"],csrf=False)
    def prescriptions(self,**kw):
        try:
            user=self._require_user(); Model=request.env["medibook.prescription"].sudo()
            doctor=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if request.httprequest.method=="GET":
                recs=Model.search([("doctor_id","=",doctor.id)]) if doctor else Model.browse()
                return self._json([{"id":str(x.id),"name":x.name,"consultation_id":str(x.consultation_id.id),"patient_id":str(x.patient_id.id),"state":x.state,"issued_at":x.issued_at.isoformat()+"Z" if x.issued_at else None} for x in recs])
            if not doctor:return self._error("forbidden",403)
            body=self._body(); rec=Model.create({"name":body.get("name") or "Prescription","consultation_id":int(body["consultation_id"])})
            return self._json({"id":str(rec.id),"name":rec.name,"state":rec.state},201)
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/billing/invoices",type="http",auth="none",methods=["GET"],csrf=False)
    def invoices(self,**kw):
        try:
            user=self._require_user(); patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            domain=[("patient_id","=",patient.id)] if patient else [("organization_id","=",self._org(user).id)]
            recs=request.env["medibook.invoice"].sudo().search(domain)
            return self._json([{"id":str(x.id),"name":x.name,"patient_id":str(x.patient_id.id),"amount_total":x.amount_total,"amount_paid":x.amount_paid,"state":x.state,"currency":x.currency_id.name} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/billing/invoices/<int:invoice_id>",type="http",auth="none",methods=["GET"],csrf=False)
    def invoice(self,invoice_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.invoice"].sudo().browse(invoice_id)
            if not rec.exists():return self._error("not_found",404)
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not patient or rec.patient_id.id!=patient.id:return self._error("not_found",404)
            return self._json({"id":str(rec.id),"name":rec.name,"amount_total":rec.amount_total,"amount_paid":rec.amount_paid,"state":rec.state,"currency":rec.currency_id.name})
        except AccessDenied:return self._error("unauthorized",401)



    def _audit(self, action, entity_type, entity_id, outcome="success", correlation_id=None, metadata=None):
        org=self._org(request.env.user)
        if not org:return
        request.env["medibook.audit.entry"].sudo().sudo().create({
            "event_id":str(uuid.uuid4()),"actor_id":request.env.user.id,"organization_id":org.id,
            "action":action,"entity_type":entity_type,"entity_id":str(entity_id),
            "outcome":outcome,"correlation_id":correlation_id or str(uuid.uuid4()),
            "metadata":metadata or {},
        })

    def _daily_request(self, path, payload):
        key=request.env["ir.config_parameter"].sudo().get_param("medibook.daily_api_key")
        domain=request.env["ir.config_parameter"].sudo().get_param("medibook.daily_domain")
        if not key or not domain:
            raise ValidationError("Daily telehealth is not configured.")
        response=requests.post("https://api.daily.co/v1"+path,json=payload,headers={"Authorization":"Bearer "+key,"Content-Type":"application/json"},timeout=10)
        if response.status_code >= 400:
            raise ValidationError("Daily provider request failed.")
        return response.json()

    def _daily_token(self, room_name, user):
        exp=int((datetime.utcnow()+timedelta(minutes=10)).timestamp())
        data=self._daily_request("/meeting-tokens",{
          "properties":{"room_name":room_name,"user_id":str(user.id),"user_name":user.name,"exp":exp,"eject_at_token_exp":True}
        })
        return data["token"],datetime.utcfromtimestamp(exp)

    @http.route("/telehealth/sessions",type="http",auth="none",methods=["POST"],csrf=False)
    def create_telehealth_session(self,**kw):
        try:
            user=self._require_user(); body=self._body()
            appointment=request.env["medibook.appointment"].sudo().browse(int(body["appointment_id"]))
            if not appointment.exists():return self._error("not_found",404)
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            practitioner=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not ((patient and appointment.patient_id.id==patient.id) or (practitioner and appointment.doctor_id.id==practitioner.id)):
                return self._error("forbidden",403)
            if not appointment.is_telehealth:return self._error("not_telehealth",422)
            if appointment.status not in ("scheduled","checked_in"):return self._error("invalid_state",409)
            Session=request.env["medibook.telehealth.session"].sudo()
            existing=Session.search([("appointment_id","=",appointment.id),("ended_at","=",False)],limit=1)
            if existing:
                return self._error("session_exists",409)
            room=self._daily_request("/rooms",{"name":"medibook-"+str(appointment.id)+"-"+uuid.uuid4().hex[:12],"properties":{"privacy":"private","enable_prejoin_ui":False}}) 
            room_name=room["name"]; room_url=room["url"]
            token,expires=self._daily_token(room_name,user)
            session=Session.create({"name":"TH-"+str(appointment.id),"appointment_id":appointment.id,"room_id":room_name,"room_url":room_url,"token_expires_at":expires,"join_token_hash":hashlib.sha256(token.encode()).hexdigest()})
            self._audit("telehealth_session_created","appointment",appointment.id)
            return self._json({"id":str(session.id),"appointment_id":str(appointment.id),"provider":"daily","join_token":token,"expires_at":expires.isoformat()+"Z","room_url":room_url,"room_id":room_name,"host_user_id":str(appointment.doctor_id.user_id.id) if appointment.doctor_id.user_id else None},201)
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,KeyError,ValueError) as e:return self._error("telehealth_error",422,str(e))

    @http.route("/telehealth/sessions/<int:session_id>/join",type="http",auth="none",methods=["POST"],csrf=False)
    def refresh_telehealth_token(self,session_id,**kw):
        try:
            user=self._require_user(); session=request.env["medibook.telehealth.session"].sudo().browse(session_id)
            if not session.exists() or session.ended_at:return self._error("not_found",404)
            appointment=session.appointment_id
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            practitioner=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not ((patient and appointment.patient_id.id==patient.id) or (practitioner and appointment.doctor_id.id==practitioner.id)):return self._error("forbidden",403)
            if session.token_consumed:return self._error("token_already_consumed",409)
            token,expires=self._daily_token(session.room_id,user)
            session.write({"token_expires_at":expires,"join_token_hash":hashlib.sha256(token.encode()).hexdigest()})
            return self._json({"join_token":token,"expires_at":expires.isoformat()+"Z"})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/telehealth/sessions/<int:session_id>/joined",type="http",auth="none",methods=["POST"],csrf=False)
    def mark_telehealth_joined(self,session_id,**kw):
        try:
            user=self._require_user(); session=request.env["medibook.telehealth.session"].sudo().browse(session_id)
            if not session.exists() or session.ended_at:return self._error("not_found",404)
            if session.joined_at:return self._error("already_joined",409)
            appointment=session.appointment_id
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            practitioner=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not ((patient and appointment.patient_id.id==patient.id) or (practitioner and appointment.doctor_id.id==practitioner.id)):return self._error("forbidden",403)
            session.write({"joined_at":fields.Datetime.now(),"token_consumed":True})
            if practitioner:
                consultation=request.env["medibook.consultation"].sudo().search([("appointment_id","=",appointment.id)],limit=1)
                if not consultation:consultation=request.env["medibook.consultation"].sudo().create({"name":"CONS-"+str(appointment.id),"appointment_id":appointment.id})
                if consultation.state=="draft":consultation.action_start()
            self._audit("telehealth_joined","telehealth.session",session.id)
            return self._json({})
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,AccessError) as e:return self._error("telehealth_error",422,str(e))

    @http.route("/telehealth/sessions/<int:session_id>/end",type="http",auth="none",methods=["POST"],csrf=False)
    def end_telehealth(self,session_id,**kw):
        try:
            user=self._require_user(); session=request.env["medibook.telehealth.session"].sudo().browse(session_id)
            if not session.exists():return self._error("not_found",404)
            appointment=session.appointment_id
            patient=request.env["medibook.patient"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            practitioner=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not ((patient and appointment.patient_id.id==patient.id) or (practitioner and appointment.doctor_id.id==practitioner.id)):return self._error("forbidden",403)
            session.write({"ended_at":fields.Datetime.now()})
            key=request.env["ir.config_parameter"].sudo().get_param("medibook.daily_api_key")
            if key:
                requests.delete("https://api.daily.co/v1/rooms/"+session.room_id,headers={"Authorization":"Bearer "+key},timeout=10)
            self._audit("telehealth_ended","telehealth.session",session.id)
            return self._json({})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/consultations/<int:consultation_id>/start",type="http",auth="none",methods=["POST"],csrf=False)
    def start_consultation(self,consultation_id,**kw):
        try:
            user=self._require_user(); c=request.env["medibook.consultation"].sudo().browse(consultation_id)
            doctor=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not doctor or c.doctor_id.id!=doctor.id:return self._error("forbidden",403)
            c.action_start(); self._audit("consultation_started","consultation",c.id); return self._json(self._consultation_json(c))
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,AccessError) as e:return self._error("validation_error",422,str(e))

    @http.route("/consultations/<int:consultation_id>/sign",type="http",auth="none",methods=["POST"],csrf=False)
    def sign_consultation(self,consultation_id,**kw):
        try:
            user=self._require_user(); c=request.env["medibook.consultation"].sudo().browse(consultation_id)
            doctor=request.env["medibook.practitioner"].sudo().sudo().search([("user_id","=",user.id)],limit=1)
            if not doctor or c.doctor_id.id!=doctor.id:return self._error("forbidden",403)
            c.action_sign(); self._audit("consultation_signed","consultation",c.id); return self._json(self._consultation_json(c))
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,AccessError) as e:return self._error("validation_error",422,str(e))


    def _admin_allowed(self,user):
        return user.has_group("medibook_base.group_medibook_clinic_admin") or user.has_group("medibook_base.group_medibook_org_admin") or user.has_group("medibook_base.group_medibook_super_admin")

    @http.route("/clinics",type="http",auth="none",methods=["POST"],csrf=False)
    def create_clinic(self,**kw):
        try:
            user=self._require_user()
            if not self._admin_allowed(user):return self._error("forbidden",403)
            body=self._body(); org=self._org(user)
            rec=request.env["medibook.clinic"].sudo().create({"name":body["name"],"code":body["code"],"organization_id":org.id,"timezone":body.get("timezone") or "UTC","address":body.get("address")})
            self._audit("clinic_created","clinic",rec.id)
            return self._json({"id":str(rec.id),"name":rec.name,"code":rec.code,"organization_id":str(org.id),"timezone":rec.timezone},201)
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,KeyError) as e:return self._error("validation_error",422,str(e))

    @http.route("/clinics/<int:clinic_id>",type="http",auth="none",methods=["GET","PATCH"],csrf=False)
    def clinic_detail(self,clinic_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.clinic"].sudo().browse(clinic_id); org=self._org(user)
            if not rec.exists() or rec.organization_id.id!=org.id:return self._error("not_found",404)
            if request.httprequest.method=="PATCH":
                if not self._admin_allowed(user):return self._error("forbidden",403)
                body=self._body(); allowed={k:body[k] for k in ("name","code","timezone","address","active") if k in body}; rec.write(allowed); self._audit("clinic_updated","clinic",rec.id)
            return self._json({"id":str(rec.id),"name":rec.name,"code":rec.code,"organization_id":str(org.id),"timezone":rec.timezone,"address":rec.address,"active":rec.active})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/doctors",type="http",auth="none",methods=["POST"],csrf=False)
    def create_doctor(self,**kw):
        try:
            user=self._require_user()
            if not self._admin_allowed(user):return self._error("forbidden",403)
            body=self._body(); org=self._org(user)
            rec=request.env["medibook.practitioner"].sudo().create({"name":body["name"],"organization_id":org.id,"specialty":body.get("specialty"),"avatar_url":body.get("avatar_url"),"clinic_ids":[(6,0,[int(x) for x in body.get("clinic_ids",[])])]})
            self._audit("doctor_created","practitioner",rec.id)
            return self._json({"id":str(rec.id),"name":rec.name,"specialty":rec.specialty,"avatar_url":rec.avatar_url,"clinic_ids":[str(x.id) for x in rec.clinic_ids]},201)
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,KeyError,ValueError) as e:return self._error("validation_error",422,str(e))

    @http.route("/doctors/<int:doctor_id>",type="http",auth="none",methods=["GET","PATCH"],csrf=False)
    def doctor_detail(self,doctor_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.practitioner"].sudo().browse(doctor_id); org=self._org(user)
            if not rec.exists() or rec.organization_id.id!=org.id:return self._error("not_found",404)
            if request.httprequest.method=="PATCH":
                if not self._admin_allowed(user):return self._error("forbidden",403)
                body=self._body(); vals={k:body[k] for k in ("name","specialty","avatar_url","active") if k in body}
                if "clinic_ids" in body:vals["clinic_ids"]=[(6,0,[int(x) for x in body["clinic_ids"]])]
                rec.write(vals); self._audit("doctor_updated","practitioner",rec.id)
            return self._json({"id":str(rec.id),"name":rec.name,"specialty":rec.specialty,"avatar_url":rec.avatar_url,"clinic_ids":[str(x.id) for x in rec.clinic_ids],"active":rec.active})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/medical-services",type="http",auth="none",methods=["POST"],csrf=False)
    def create_service(self,**kw):
        try:
            user=self._require_user()
            if not self._admin_allowed(user):return self._error("forbidden",403)
            body=self._body(); org=self._org(user)
            rec=request.env["medibook.medical.service"].sudo().create({"name":body["name"],"code":body["code"],"organization_id":org.id,"duration_minutes":int(body.get("duration_minutes",30)),"price":float(body.get("price",0)),"clinic_ids":[(6,0,[int(x) for x in body.get("clinic_ids",[])])]})
            self._audit("service_created","medical.service",rec.id)
            return self._json({"id":str(rec.id),"name":rec.name,"code":rec.code,"duration_minutes":rec.duration_minutes,"price":rec.price,"currency":rec.currency_id.name},201)
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,KeyError,ValueError) as e:return self._error("validation_error",422,str(e))

    @http.route("/medical-services/<int:service_id>",type="http",auth="none",methods=["GET","PATCH"],csrf=False)
    def service_detail(self,service_id,**kw):
        try:
            user=self._require_user(); rec=request.env["medibook.medical.service"].sudo().browse(service_id); org=self._org(user)
            if not rec.exists() or rec.organization_id.id!=org.id:return self._error("not_found",404)
            if request.httprequest.method=="PATCH":
                if not self._admin_allowed(user):return self._error("forbidden",403)
                body=self._body(); vals={k:body[k] for k in ("name","code","active") if k in body}
                if "duration_minutes" in body:vals["duration_minutes"]=int(body["duration_minutes"])
                if "price" in body:vals["price"]=float(body["price"])
                if "clinic_ids" in body:vals["clinic_ids"]=[(6,0,[int(x) for x in body["clinic_ids"]])]
                rec.write(vals); self._audit("service_updated","medical.service",rec.id)
            return self._json({"id":str(rec.id),"name":rec.name,"code":rec.code,"duration_minutes":rec.duration_minutes,"price":rec.price,"currency":rec.currency_id.name,"active":rec.active})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/reports",type="http",auth="none",methods=["GET"],csrf=False)
    def reports(self,**kw):
        try:
            user=self._require_user()
            if not self._admin_allowed(user):return self._error("forbidden",403)
            org=self._org(user); domain=[("organization_id","=",org.id)]
            date_from=request.httprequest.args.get("from"); date_to=request.httprequest.args.get("to")
            if date_from:domain.append(("starts_at",">=",date_from))
            if date_to:domain.append(("starts_at","<=",date_to))
            appointments=request.env["medibook.appointment"].sudo().search(domain)
            by_status={s:len(appointments.filtered(lambda x:x.status==s)) for s in ("scheduled","checked_in","in_consultation","completed","cancelled","no_show")}
            return self._json({"appointment_volume":len(appointments),"appointment_status":by_status})
        except AccessDenied:return self._error("unauthorized",401)

    @http.route("/audit",type="http",auth="none",methods=["GET"],csrf=False)
    def audit_entries(self,**kw):
        try:
            user=self._require_user()
            if not user.has_group("medibook_base.group_medibook_org_admin"):return self._error("forbidden",403)
            org=self._org(user); domain=[("organization_id","=",org.id)]
            entity_type=request.httprequest.args.get("entity_type"); entity_id=request.httprequest.args.get("entity_id")
            if entity_type:domain.append(("entity_type","=",entity_type))
            if entity_id:domain.append(("entity_id","=",entity_id))
            recs=request.env["medibook.audit.entry"].sudo().search(domain,limit=200)
            return self._json([{"event_id":x.event_id,"actor_id":str(x.actor_id.id),"organization_id":str(x.organization_id.id),"action":x.action,"entity_type":x.entity_type,"entity_id":x.entity_id,"timestamp":x.timestamp.isoformat()+"Z","outcome":x.outcome,"correlation_id":x.correlation_id} for x in recs])
        except AccessDenied:return self._error("unauthorized",401)


    @http.route("/doctors/<int:doctor_id>/availability",type="http",auth="none",methods=["GET","POST"],csrf=False)
    def doctor_availability(self,doctor_id,**kw):
        try:
            user=self._require_user(); doctor=request.env["medibook.practitioner"].sudo().browse(doctor_id); org=self._org(user)
            if not doctor.exists() or doctor.organization_id.id!=org.id:return self._error("not_found",404)
            Schedule=request.env["medibook.schedule"].sudo()
            if request.httprequest.method=="GET":
                recs=Schedule.search([("doctor_id","=",doctor.id),("active","=",True)])
                return self._json([{"id":str(x.id),"doctor_id":str(doctor.id),"clinic_id":str(x.clinic_id.id),"weekday":x.weekday,"start_time":x.start_time,"end_time":x.end_time} for x in recs])
            if not self._admin_allowed(user):return self._error("forbidden",403)
            body=self._body()
            rec=Schedule.create({"name":body.get("name") or doctor.name,"doctor_id":doctor.id,"clinic_id":int(body["clinic_id"]),"weekday":int(body["weekday"]),"start_time":float(body["start_time"]),"end_time":float(body["end_time"])})
            self._audit("doctor_schedule_created","schedule",rec.id)
            return self._json({"id":str(rec.id),"doctor_id":str(doctor.id),"clinic_id":str(rec.clinic_id.id),"weekday":rec.weekday,"start_time":rec.start_time,"end_time":rec.end_time},201)
        except AccessDenied:return self._error("unauthorized",401)
        except (ValidationError,KeyError,ValueError) as e:return self._error("validation_error",422,str(e))

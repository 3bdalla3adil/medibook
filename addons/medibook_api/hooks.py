import os

from odoo import SUPERUSER_ID, api

DEMO_USERS = (
    ("demo.patient@medibook.app", "MediBook Demo Patient", "patient"),
    ("demo.doctor@medibook.app", "MediBook Demo Doctor", "doctor"),
    ("demo.admin@medibook.app", "MediBook Demo Administrator", "admin"),
)

def seed_demo_users(env):
    password=os.getenv("MEDIBOOK_DEMO_PASSWORD")
    if not password:
        return
    company=env.company
    Org=env["medibook.organization"].sudo()
    org=Org.search([("code","=","DEMO")],limit=1)
    if not org:
        org=Org.create({"name":"MediBook Demo Organization","code":"DEMO","company_id":company.id})
    Clinic=env["medibook.clinic"].sudo()
    clinic=Clinic.search([("code","=","DEMO-CLINIC"),("organization_id","=",org.id)],limit=1)
    if not clinic:
        clinic=Clinic.create({"name":"MediBook Demo Clinic","code":"DEMO-CLINIC","organization_id":org.id,"timezone":"Africa/Khartoum"})
    Service=env["medibook.medical.service"].sudo()
    service=Service.search([("code","=","DEMO-CONSULT"),("organization_id","=",org.id)],limit=1)
    if not service:
        service=Service.create({"name":"General Consultation","code":"DEMO-CONSULT","organization_id":org.id,"duration_minutes":30,"price":0,"clinic_ids":[(4,clinic.id)]})
    Users=env["res.users"].sudo()
    groups={
      "patient":[env.ref("base.group_portal").id,env.ref("medibook_base.group_medibook_patient").id],
      "doctor":[env.ref("base.group_user").id,env.ref("medibook_base.group_medibook_doctor").id],
      "admin":[env.ref("base.group_user").id,env.ref("medibook_base.group_medibook_org_admin").id],
    }
    for login,name,role in DEMO_USERS:
        user=Users.search([("login","=",login)],limit=1)
        vals={"name":name,"login":login,"password":password,"company_id":company.id,"company_ids":[(6,0,[company.id])],"group_ids":[(6,0,groups[role])],"medibook_organization_id":org.id,"medibook_clinic_ids":[(4,clinic.id)]}
        if user:user.write(vals)
        else:user=Users.create(vals)
        if role=="patient":
            Patient=env["medibook.patient"].sudo()
            if not Patient.search([("user_id","=",user.id)],limit=1):
                Patient.create({"name":name,"user_id":user.id,"organization_id":org.id,"preferred_locale":"ar"})
        elif role=="doctor":
            Practitioner=env["medibook.practitioner"].sudo()
            if not Practitioner.search([("user_id","=",user.id)],limit=1):
                Practitioner.create({"name":name,"user_id":user.id,"organization_id":org.id,"clinic_ids":[(4,clinic.id)],"specialty":"General Medicine"})

def post_init_hook(env):
    seed_demo_users(env)

from odoo import api, fields, models
from odoo.exceptions import ValidationError

class MediBookAppointment(models.Model):
    _name="medibook.appointment"
    _description="MediBook Appointment"
    _rec_name="name"
    _order="starts_at asc"

    name=fields.Char(required=True,index=True)
    clinic_id=fields.Many2one("medibook.clinic",required=True,index=True,ondelete="restrict")
    patient_id=fields.Many2one("medibook.patient",required=True,index=True,ondelete="restrict")
    doctor_id=fields.Many2one("medibook.practitioner",required=True,index=True,ondelete="restrict")
    service_id=fields.Many2one("medibook.medical.service",required=True,index=True,ondelete="restrict")
    starts_at=fields.Datetime(required=True,index=True)
    duration_minutes=fields.Integer(required=True,default=30)
    status=fields.Selection([
      ("scheduled","Scheduled"),("checked_in","Checked In"),("in_consultation","In Consultation"),
      ("completed","Completed"),("cancelled","Cancelled"),("no_show","No Show")
    ],required=True,default="scheduled",index=True)
    is_telehealth=fields.Boolean(default=False)
    room_label=fields.Char()
    cancellation_reason=fields.Text()
    cancelled_at=fields.Datetime()
    notes=fields.Text()
    triage_bp_systolic=fields.Integer()
    triage_bp_diastolic=fields.Integer()
    triage_heart_rate=fields.Integer()
    triage_temperature_c=fields.Float()
    triage_spo2=fields.Integer()
    triage_weight_kg=fields.Float()
    triage_height_cm=fields.Float()
    triage_respiratory_rate=fields.Integer()
    triage_pain_score=fields.Integer()
    triage_note=fields.Text()
    triage_urgent=fields.Boolean(default=False)
    version=fields.Integer(required=True,default=1,index=True)
    idempotency_key=fields.Char(index=True,copy=False)
    organization_id=fields.Many2one(related="clinic_id.organization_id",store=True,index=True)

    _duration_check=models.Constraint("CHECK(duration_minutes > 0)","Appointment duration must be positive.")
    _idempotency_unique=models.Constraint("UNIQUE(idempotency_key)","Idempotency key must be unique when provided.")

    @api.model
    def _slot_domain(self, doctor_id, starts_at, duration_minutes, exclude_id=False):
        end = fields.Datetime.to_datetime(starts_at) + __import__("datetime").timedelta(minutes=duration_minutes)
        domain=[("doctor_id","=",doctor_id),("status","in",["scheduled","checked_in","in_consultation"]),
                ("starts_at","<",end)]
        if exclude_id: domain.append(("id","!=",exclude_id))
        return domain

    @api.constrains("doctor_id","starts_at","duration_minutes","status")
    def write(self, vals):
        for rec in self:
            values=dict(vals)
            if not self.env.context.get("_skip_version"):
                values["version"]=rec.version+1
            super(MediBookAppointment, rec).write(values)
        return True

    def _check_overlap(self):
        for rec in self:
            if rec.status in ("completed","cancelled","no_show"): continue
            if self.search_count(self._slot_domain(rec.doctor_id.id,rec.starts_at,rec.duration_minutes,rec.id)):
                raise ValidationError("The doctor already has an overlapping appointment.")

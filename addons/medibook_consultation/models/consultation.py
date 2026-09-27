from odoo import api, fields, models

class MediBookConsultation(models.Model):
    _name="medibook.consultation"
    _description="MediBook Clinical Consultation"
    _order="started_at desc"

    name=fields.Char(required=True)
    appointment_id=fields.Many2one("medibook.appointment",required=True,index=True,ondelete="restrict")
    patient_id=fields.Many2one(related="appointment_id.patient_id",store=True,index=True)
    doctor_id=fields.Many2one(related="appointment_id.doctor_id",store=True,index=True)
    organization_id=fields.Many2one(related="appointment_id.organization_id",store=True,index=True)
    state=fields.Selection([("draft","Draft"),("in_progress","In Progress"),("completed","Completed")],default="draft",required=True,index=True)
    started_at=fields.Datetime()
    completed_at=fields.Datetime()
    notes=fields.Text()
    diagnosis=fields.Text()
    signed_at=fields.Datetime()
    signed_by=fields.Many2one("res.users")
    supersedes_id=fields.Many2one("medibook.consultation",index=True,ondelete="restrict")

    _appointment_unique=models.Constraint("UNIQUE(appointment_id)","An appointment can have only one consultation.")

    def action_start(self):
        self.ensure_one()
        if self.state != "draft": raise models.UserError("Only draft consultations can start.")
        self.write({"state":"in_progress","started_at":fields.Datetime.now()})
        self.appointment_id.write({"status":"in_consultation"})
        return True

    def action_complete(self):
        self.ensure_one()
        if self.state != "in_progress": raise models.UserError("Only active consultations can complete.")
        if not self.signed_at: raise models.UserError("The consultation must be signed before completion.")
        self.write({"state":"completed","completed_at":fields.Datetime.now()})
        self.appointment_id.write({"status":"completed"})
        return True

    def action_sign(self):
        for rec in self:
            if rec.state != "in_progress": raise models.UserError("Only active consultations can be signed.")
            rec.write({"signed_at":fields.Datetime.now(),"signed_by":self.env.user.id})
        return True

    def write(self, vals):
        for rec in self:
            if rec.signed_at and any(k in vals for k in ("notes","diagnosis","patient_id","doctor_id","appointment_id")):
                raise models.UserError("Signed consultation notes are immutable; create an amendment.")
        return super().write(vals)

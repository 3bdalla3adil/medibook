from odoo import fields, models
from odoo.exceptions import UserError

class MediBookMedication(models.Model):
    _name="medibook.medication"
    _description="MediBook Medication"
    _rec_name="name"
    name=fields.Char(required=True,index=True)
    code=fields.Char(required=True,index=True)
    active=fields.Boolean(default=True)
    _code_unique=models.Constraint("UNIQUE(code)","Medication code must be unique.")

class MediBookPrescription(models.Model):
    _name="medibook.prescription"
    _description="MediBook Prescription"
    _order="issued_at desc"
    name=fields.Char(required=True)
    consultation_id=fields.Many2one("medibook.consultation",required=True,index=True,ondelete="restrict")
    patient_id=fields.Many2one(related="consultation_id.patient_id",store=True,index=True)
    doctor_id=fields.Many2one(related="consultation_id.doctor_id",store=True,index=True)
    state=fields.Selection([("draft","Draft"),("issued","Issued"),("cancelled","Cancelled")],default="draft",required=True)
    issued_at=fields.Datetime()
    line_ids=fields.One2many("medibook.prescription.line","prescription_id")

    def action_issue(self):
        for rec in self:
            if rec.state != "draft": raise UserError("Only draft prescriptions can be issued.")
            if rec.consultation_id.state != "in_progress": raise models.UserError("Prescription requires an active consultation.")
            if not rec.line_ids: raise models.UserError("Prescription must contain at least one medication.")
            rec.write({"state":"issued","issued_at":fields.Datetime.now()})

class MediBookPrescriptionLine(models.Model):
    _name="medibook.prescription.line"
    _description="MediBook Prescription Line"
    prescription_id=fields.Many2one("medibook.prescription",required=True,ondelete="cascade")
    medication_id=fields.Many2one("medibook.medication",required=True,ondelete="restrict")
    dosage=fields.Char(required=True)
    frequency=fields.Char(required=True)
    duration=fields.Char(required=True)
    instructions=fields.Text()

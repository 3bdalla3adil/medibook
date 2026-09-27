from odoo import fields, models

class MediBookMedicalHistory(models.Model):
    _name = "medibook.medical.history"
    _description = "MediBook Medical History"
    _order = "event_date desc, id desc"

    patient_id = fields.Many2one("medibook.patient", required=True, index=True, ondelete="restrict")
    event_date = fields.Datetime(required=True)
    title = fields.Char(required=True)
    summary = fields.Text(required=True)
    supersedes_id = fields.Many2one("medibook.medical.history", index=True, ondelete="restrict")
    author_id = fields.Many2one("res.users", required=True, default=lambda self: self.env.user, ondelete="restrict")
    organization_id = fields.Many2one(related="patient_id.organization_id", store=True, index=True)

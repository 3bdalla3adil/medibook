from odoo import fields, models

class MediBookPatient(models.Model):
    _name = "medibook.patient"
    _description = "MediBook Patient"
    _rec_name = "name"

    name = fields.Char(required=True, index=True)
    user_id = fields.Many2one("res.users", index=True, ondelete="set null")
    organization_id = fields.Many2one("medibook.organization", required=True, index=True, ondelete="restrict")
    avatar_url = fields.Char()
    preferred_locale = fields.Char()
    date_of_birth = fields.Date()
    active = fields.Boolean(default=True)
    appointment_ids = fields.One2many("medibook.appointment", "patient_id")

    _user_unique = models.Constraint("UNIQUE(user_id)", "A user can be linked to only one patient.")

from odoo import fields, models

class MediBookPractitioner(models.Model):
    _name = "medibook.practitioner"
    _description = "MediBook Practitioner"
    _rec_name = "name"

    name = fields.Char(required=True, index=True)
    user_id = fields.Many2one("res.users", index=True, ondelete="set null")
    organization_id = fields.Many2one("medibook.organization", required=True, index=True, ondelete="restrict")
    clinic_ids = fields.Many2many("medibook.clinic", string="Clinics")
    specialty = fields.Char()
    avatar_url = fields.Char()
    is_portal_doctor = fields.Boolean(default=True)
    active = fields.Boolean(default=True)

    _user_unique = models.Constraint(
        "UNIQUE(user_id)",
        "A user can be linked to only one practitioner.",
    )

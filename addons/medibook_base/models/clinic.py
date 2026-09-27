from odoo import fields, models

class MediBookClinic(models.Model):
    _name = "medibook.clinic"
    _description = "MediBook Clinic"
    _rec_name = "name"

    name = fields.Char(required=True, index=True)
    code = fields.Char(required=True, index=True)
    organization_id = fields.Many2one("medibook.organization", required=True, index=True, ondelete="restrict")
    address = fields.Text()
    timezone = fields.Char(default="UTC", required=True)
    active = fields.Boolean(default=True)
    practitioner_ids = fields.Many2many("medibook.practitioner", string="Practitioners")
    service_ids = fields.Many2many("medibook.medical.service", string="Services")

    _code_org_unique = models.Constraint(
        "UNIQUE(organization_id, code)",
        "Clinic code must be unique within an organization.",
    )

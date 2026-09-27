from odoo import fields, models

class MediBookOrganization(models.Model):
    _name = "medibook.organization"
    _description = "MediBook Organization"
    _rec_name = "name"

    name = fields.Char(required=True, index=True)
    code = fields.Char(required=True, index=True)
    active = fields.Boolean(default=True)
    company_id = fields.Many2one("res.company", required=True, default=lambda self: self.env.company, index=True)
    clinic_ids = fields.One2many("medibook.clinic", "organization_id")

    _code_unique = models.Constraint(
        "UNIQUE(code)",
        "Organization code must be unique.",
    )

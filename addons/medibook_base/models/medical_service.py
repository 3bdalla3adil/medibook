from odoo import fields, models

class MediBookMedicalService(models.Model):
    _name = "medibook.medical.service"
    _description = "MediBook Medical Service"
    _rec_name = "name"

    name = fields.Char(required=True, index=True)
    code = fields.Char(required=True, index=True)
    organization_id = fields.Many2one("medibook.organization", required=True, index=True, ondelete="restrict")
    clinic_ids = fields.Many2many("medibook.clinic", string="Clinics")
    duration_minutes = fields.Integer(default=30, required=True)
    price = fields.Monetary(currency_field="currency_id", required=True, default=0)
    currency_id = fields.Many2one("res.currency", required=True, default=lambda self: self.env.company.currency_id)
    active = fields.Boolean(default=True)

    _code_org_unique = models.Constraint(
        "UNIQUE(organization_id, code)",
        "Service code must be unique within an organization.",
    )

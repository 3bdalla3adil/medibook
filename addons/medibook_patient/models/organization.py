from odoo import fields, models

class MediBookOrganization(models.Model):
    _inherit="medibook.organization"
    patient_ids=fields.One2many("medibook.patient","organization_id")

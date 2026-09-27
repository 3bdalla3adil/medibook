from odoo import fields, models

class ResUsers(models.Model):
    _inherit="res.users"

    medibook_organization_id=fields.Many2one("medibook.organization",index=True,ondelete="restrict")
    medibook_clinic_ids=fields.Many2many("medibook.clinic",string="MediBook Clinics")

from odoo import fields, models

class MediBookInvitation(models.Model):
    _name = 'medibook.invitation'
    _description = 'MediBook Registration Invitation'
    _rec_name = 'email'

    token = fields.Char(required=True, index=True)
    email = fields.Char(required=True, index=True)
    role = fields.Selection([('doctor','Doctor'),('receptionist','Receptionist'),('clinicAdmin','Clinic Admin'),('orgAdmin','Organization Admin')], required=True)
    organization_id = fields.Many2one('medibook.organization', required=True, ondelete='restrict')
    clinic_ids = fields.Many2many('medibook.clinic')
    invited_by_id = fields.Many2one('res.users', required=True, ondelete='restrict')
    expires_at = fields.Datetime(required=True)
    accepted_at = fields.Datetime(readonly=True)
    accepted_by_id = fields.Many2one('res.users', readonly=True, ondelete='set null')

    _token_unique = models.Constraint('UNIQUE(token)', 'Invitation token must be unique.')
    _expiry_check = models.Constraint('CHECK(expires_at > create_date)', 'Invitation must expire after creation.')

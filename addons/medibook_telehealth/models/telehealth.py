from odoo import fields, models

class MediBookTelehealthSession(models.Model):
    _name='medibook.telehealth.session'; _description='MediBook WebRTC signaling session'
    appointment_id=fields.Many2one('medibook.appointment',required=True,ondelete='restrict'); host_user_id=fields.Many2one('res.users',required=True); guest_user_id=fields.Many2one('res.users',required=True); status=fields.Selection([('created','Created'),('active','Active'),('ended','Ended')],default='created',required=True); started_at=fields.Datetime(); ended_at=fields.Datetime(); ended_by_id=fields.Many2one('res.users'); end_reason=fields.Char(); session_token=fields.Char(required=True,index=True); expires_at=fields.Datetime(required=True)
    _token_unique=models.Constraint('UNIQUE(session_token)','Session token must be unique.')
    _appointment_unique=models.Constraint('UNIQUE(appointment_id)','An appointment may have one signaling session.')
class MediBookTelehealthSignal(models.Model):
    _name='medibook.telehealth.signal'; _description='MediBook WebRTC signal'
    session_id=fields.Many2one('medibook.telehealth.session',required=True,ondelete='cascade'); sender_id=fields.Many2one('res.users',required=True); kind=fields.Selection([('call:offer','Offer'),('call:answer','Answer'),('call:ice','ICE'),('call:end','End'),('call:state','State')],required=True); payload=fields.Text(required=True); created_at=fields.Datetime(default=fields.Datetime.now,required=True)

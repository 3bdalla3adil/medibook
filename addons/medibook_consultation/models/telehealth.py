from odoo import fields, models

class MediBookTelehealthSession(models.Model):
    _name="medibook.telehealth.session"
    _description="MediBook Telehealth Session"
    _rec_name="name"

    name=fields.Char(required=True,index=True)
    appointment_id=fields.Many2one("medibook.appointment",required=True,index=True,ondelete="restrict")
    provider=fields.Selection([("daily","Daily")],required=True,default="daily")
    room_id=fields.Char(required=True,index=True)
    room_url=fields.Char(required=True)
    join_token_hash=fields.Char(copy=False)
    token_expires_at=fields.Datetime(required=True,index=True)
    token_consumed=fields.Boolean(default=False,index=True)
    joined_at=fields.Datetime()
    ended_at=fields.Datetime()
    organization_id=fields.Many2one(related="appointment_id.organization_id",store=True,index=True)

    _appointment_unique=models.Constraint("UNIQUE(appointment_id)","An appointment may have only one active telehealth session.")

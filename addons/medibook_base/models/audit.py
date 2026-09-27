from odoo import fields, models

class MediBookAuditEntry(models.Model):
    _name="medibook.audit.entry"
    _description="MediBook Audit Entry"
    _order="timestamp desc,id desc"

    event_id=fields.Char(required=True,index=True)
    actor_id=fields.Many2one("res.users",required=True,index=True,ondelete="restrict")
    organization_id=fields.Many2one("medibook.organization",required=True,index=True,ondelete="restrict")
    action=fields.Char(required=True,index=True)
    entity_type=fields.Char(required=True,index=True)
    entity_id=fields.Char(required=True,index=True)
    timestamp=fields.Datetime(required=True,index=True,default=fields.Datetime.now)
    outcome=fields.Selection([("success","Success"),("failure","Failure")],required=True)
    correlation_id=fields.Char(index=True)
    metadata=fields.Json()

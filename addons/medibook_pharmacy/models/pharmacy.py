from odoo import fields, models
class MediBookPharmacy(models.Model):
 _name='medibook.pharmacy'; _description='MediBook pharmacy'; name=fields.Char(required=True); organization_id=fields.Many2one('medibook.organization',required=True,ondelete='restrict'); pharmacist_ids=fields.Many2many('res.users')
class MediBookDispenseRecord(models.Model):
 _name='medibook.dispense.record'; _description='Medication dispense record'; prescription_id=fields.Many2one('medibook.prescription',required=True,ondelete='restrict'); pharmacy_id=fields.Many2one('medibook.pharmacy',required=True,ondelete='restrict'); patient_id=fields.Many2one('medibook.patient',required=True,ondelete='restrict'); pharmacist_id=fields.Many2one('res.users',required=True); status=fields.Selection([('verified','Verified'),('dispensed','Dispensed'),('partial','Partially dispensed'),('rejected','Rejected')],default='verified',required=True); patient_notified=fields.Boolean(); notes=fields.Text(); dispensed_at=fields.Datetime()

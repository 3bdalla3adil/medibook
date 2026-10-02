from odoo import api, fields, models
class MediBookMedication(models.Model):
 _name='medibook.medication'; _description='Medication catalog'; name=fields.Char(required=True); name_ar=fields.Char(); form=fields.Char(); strength=fields.Char(); manufacturer=fields.Char(); is_controlled=fields.Boolean(); code=fields.Char(required=True)
 _code_unique=models.Constraint('UNIQUE(code)','Medication code must be unique.')
class MediBookPatientMedication(models.Model):
 _name='medibook.patient.medication'; _description='Patient medication'; patient_id=fields.Many2one('medibook.patient',required=True,ondelete='restrict'); medication_id=fields.Many2one('medibook.medication',required=True,ondelete='restrict'); dose=fields.Char(required=True); route=fields.Char(); frequency=fields.Char(required=True); duration_days=fields.Integer(); start_date=fields.Date(required=True); end_date=fields.Date(); prescribed_by=fields.Many2one('res.users',required=True); notes=fields.Text(); is_active=fields.Boolean(default=True); schedule_ids=fields.One2many('medibook.medication.schedule','patient_medication_id')
class MediBookMedicationSchedule(models.Model):
 _name='medibook.medication.schedule'; _description='Medication schedule'; patient_medication_id=fields.Many2one('medibook.patient.medication',required=True,ondelete='cascade'); time_of_day=fields.Integer(required=True); days_of_week=fields.Char(required=True); reminder_enabled=fields.Boolean(default=True); reminder_lead_minutes=fields.Integer(default=15)
 _time_check=models.Constraint('CHECK(time_of_day >= 0 AND time_of_day < 1440)','Time must be minutes since midnight.')
class MediBookMedicationDoseLog(models.Model):
 _name='medibook.medication.dose.log'; _description='Medication dose log'; patient_medication_id=fields.Many2one('medibook.patient.medication',required=True,ondelete='cascade'); scheduled_at=fields.Datetime(required=True); taken_at=fields.Datetime(); status=fields.Selection([('taken','Taken'),('skipped','Skipped'),('missed','Missed')],required=True); notes=fields.Text()
class MediBookMedicationReminder(models.Model):
 _name='medibook.medication.reminder'; _description='Medication reminder'; patient_medication_id=fields.Many2one('medibook.patient.medication',required=True,ondelete='cascade'); scheduled_at=fields.Datetime(required=True); sent_at=fields.Datetime(); acknowledged_at=fields.Datetime(); status=fields.Selection([('pending','Pending'),('sent','Sent'),('acknowledged','Acknowledged'),('missed','Missed')],default='pending',required=True)
 @api.model
 def _dispatch_pending_reminders(self):
  now=fields.Datetime.now(); pending=self.search([('status','=','pending'),('scheduled_at','<=',now)])
  pending.write({'status':'sent','sent_at':now})

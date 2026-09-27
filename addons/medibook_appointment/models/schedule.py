from odoo import fields, models

class MediBookSchedule(models.Model):
    _name="medibook.schedule"
    _description="MediBook Doctor Schedule"
    _rec_name="name"

    name=fields.Char(required=True)
    doctor_id=fields.Many2one("medibook.practitioner",required=True,index=True,ondelete="cascade")
    clinic_id=fields.Many2one("medibook.clinic",required=True,index=True,ondelete="cascade")
    weekday=fields.Integer(required=True)
    start_time=fields.Float(required=True)
    end_time=fields.Float(required=True)
    active=fields.Boolean(default=True)

    _weekday_check=models.Constraint("CHECK(weekday >= 0 AND weekday <= 6)","Weekday must be between 0 and 6.")
    _time_check=models.Constraint("CHECK(end_time > start_time)","Schedule end time must be after start time.")

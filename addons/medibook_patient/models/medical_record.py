from odoo import fields, models

class MediBookMedicalRecord(models.Model):
    _name="medibook.medical.record"
    _description="MediBook Medical Record"
    _order="recorded_at desc,id desc"

    patient_id=fields.Many2one("medibook.patient",required=True,index=True,ondelete="restrict")
    organization_id=fields.Many2one(related="patient_id.organization_id",store=True,index=True)
    record_type=fields.Selection([("note","Note"),("diagnosis","Diagnosis"),("lab","Lab"),("allergy","Allergy"),("history","History")],required=True)
    title=fields.Char(required=True)
    content=fields.Text(required=True)
    recorded_at=fields.Datetime(required=True)
    author_id=fields.Many2one("res.users",required=True,default=lambda self:self.env.user,ondelete="restrict")
    supersedes_id=fields.Many2one("medibook.medical.record",index=True,ondelete="restrict")
    signed_at=fields.Datetime()
    signed_by=fields.Many2one("res.users",ondelete="restrict")

    def write(self,vals):
        for rec in self:
            if rec.signed_at and any(k in vals for k in ("record_type","title","content","recorded_at","patient_id")):
                raise models.UserError("Signed medical records are append-only; create a superseding record.")
        return super().write(vals)

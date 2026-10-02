from odoo import fields, http
from odoo.http import request
class MediBookPharmacyController(http.Controller):
 def _json(self,data,status=200): return request.make_json_response({'data':data},status=status)
 def _user(self): return request.env.user
 @http.route('/medibook/api/pharmacy/queue',type='http',auth='user',methods=['GET'],csrf=False)
 def queue(self,**kw):
  user=self._user(); rows=request.env['medibook.dispense.record'].search([('pharmacy_id.pharmacist_ids','in',[user.id]),('status','in',['verified','partial'])]); return self._json([{'id':r.id,'prescription_id':r.prescription_id.id,'patient_id':r.patient_id.id,'status':r.status} for r in rows])
 @http.route('/medibook/api/pharmacy/dispense/<int:record_id>',type='http',auth='user',methods=['POST'],csrf=False)
 def dispense(self,record_id,**kw):
  user=self._user(); record=request.env['medibook.dispense.record'].search([('id','=',record_id),('pharmacy_id.pharmacist_ids','in',[user.id])],limit=1)
  if not record:return self._json({'code':'forbidden'},403)
  record.write({'status':'dispensed','pharmacist_id':user.id,'dispensed_at':fields.Datetime.now(),'patient_notified':True}); return self._json({'status':'dispensed','patient_notified':True})

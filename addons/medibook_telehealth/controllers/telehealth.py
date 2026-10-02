import json
import secrets
from datetime import timedelta
from odoo import fields, http
from odoo.exceptions import AccessDenied
from odoo.http import request

class MediBookTelehealthController(http.Controller):
    def _user(self):
        if not request.session.uid or request.env.user._is_public(): raise AccessDenied()
        return request.env.user
    def _json(self,data,status=200): return request.make_json_response({'data':data},status=status)
    def _body(self): return request.httprequest.get_json(silent=True) or {}
    @http.route('/medibook/api/telehealth/sessions',type='http',auth='user',methods=['POST'],csrf=False)
    def create(self,**kw):
        user=self._user(); body=self._body(); appointment=request.env['medibook.appointment'].browse(int(body.get('appointment_id',0)))
        if not appointment.exists() or user.id not in (appointment.patient_id.user_id.id, appointment.doctor_id.user_id.id): return self._json({'code':'forbidden'},403)
        Session=request.env['medibook.telehealth.session'].sudo(); session=Session.search([('appointment_id','=',appointment.id)],limit=1)
        if not session: session=Session.create({'appointment_id':appointment.id,'host_user_id':appointment.doctor_id.user_id.id,'guest_user_id':appointment.patient_id.user_id.id,'session_token':secrets.token_urlsafe(32),'expires_at':fields.Datetime.now()+timedelta(hours=2)})
        return self._json({'id':session.id,'token':session.session_token,'expires_at':session.expires_at.isoformat()})
    @http.route('/medibook/api/telehealth/sessions/<int:session_id>/end',type='http',auth='user',methods=['POST'],csrf=False)
    def end(self,session_id,**kw):
        user=self._user(); session=request.env['medibook.telehealth.session'].sudo().browse(session_id)
        if not session.exists() or user.id not in (session.host_user_id.id,session.guest_user_id.id): return self._json({'code':'forbidden'},403)
        session.write({'status':'ended','ended_at':fields.Datetime.now(),'ended_by_id':user.id,'end_reason':(self._body().get('reason') or 'user_ended')}); return self._json({'status':'ended'})

    @http.route('/medibook/api/telehealth/sessions/<int:session_id>/signals',type='http',auth='user',methods=['POST'],csrf=False)
    def signal(self,session_id,**kw):
        user=self._user(); body=self._body(); session=request.env['medibook.telehealth.session'].sudo().browse(session_id)
        if not session.exists() or user.id not in (session.host_user_id.id,session.guest_user_id.id): return self._json({'code':'forbidden'},403)
        kind=body.get('kind'); payload=body.get('payload')
        if kind not in ('call:offer','call:answer','call:ice','call:end','call:state') or not isinstance(payload,dict): return self._json({'code':'invalid_signal'},422)
        request.env['medibook.telehealth.signal'].sudo().create({'session_id':session.id,'sender_id':user.id,'kind':kind,'payload':json.dumps(payload)})
        return self._json({'accepted':True},202)

    @http.route('/medibook/api/telehealth/sessions/<int:session_id>/signals',type='http',auth='user',methods=['GET'],csrf=False)
    def signals(self,session_id,**kw):
        user=self._user(); session=request.env['medibook.telehealth.session'].sudo().browse(session_id)
        if not session.exists() or user.id not in (session.host_user_id.id,session.guest_user_id.id): return self._json({'code':'forbidden'},403)
        rows=request.env['medibook.telehealth.signal'].sudo().search([('session_id','=',session.id),('sender_id','!=',user.id)],order='id asc',limit=100)
        return self._json([{'kind':r.kind,'payload':json.loads(r.payload),'created_at':r.created_at.isoformat()} for r in rows])

import secrets
from datetime import datetime
from odoo import fields, http
from odoo.exceptions import AccessDenied, ValidationError
from odoo.http import request

class MediBookRegistrationController(http.Controller):
    def _json(self, data, status=200): return request.make_json_response({'data': data}, status=status)
    def _error(self, code, status): return request.make_json_response({'code': code}, status=status)
    def _body(self):
        return request.httprequest.get_json(silent=True) or {}

    @http.route('/medibook/api/registration/register', type='http', auth='none', methods=['POST'], csrf=False)
    def register_patient(self, **kw):
        body = self._body(); email = (body.get('email') or '').strip().lower(); password = body.get('password') or ''; name = (body.get('display_name') or '').strip()
        if body.get('role') not in (None, 'patient') or not email or len(password) < 8 or not name: return self._error('patient_registration_only', 422)
        Users = request.env['res.users'].sudo()
        if Users.search_count([('login', '=', email)]): return self._error('email_already_in_use', 409)
        portal = request.env.ref('base.group_portal'); patient_group = request.env.ref('medibook_base.group_medibook_patient')
        company = request.env.company; Org = request.env['medibook.organization'].sudo(); org = Org.search([('company_id','=',company.id)], limit=1)
        if not org: org = Org.create({'name': company.name, 'code': 'ORG-%s' % company.id, 'company_id': company.id})
        partner = request.env['res.partner'].sudo().create({'name': name, 'email': email})
        user = Users.create({'name':name,'login':email,'password':password,'partner_id':partner.id,'company_id':company.id,'company_ids':[(6,0,[company.id])],'group_ids':[(6,0,[portal.id,patient_group.id])],'medibook_organization_id':org.id})
        request.env['medibook.patient'].sudo().create({'name':name,'user_id':user.id,'organization_id':org.id,'preferred_locale':'ar'})
        return self._json({'user_id': str(user.id)}, 201)

    @http.route('/medibook/api/registration/invitation/<string:token>', type='http', auth='none', methods=['GET'], csrf=False)
    def validate_invitation(self, token, **kw):
        invitation = request.env['medibook.invitation'].sudo().search([('token','=',token)], limit=1)
        if not invitation or invitation.accepted_at or invitation.expires_at <= fields.Datetime.now(): return self._error('invitation_unavailable', 422)
        return self._json({'token': invitation.token, 'email': invitation.email, 'role': invitation.role, 'organization_id': invitation.organization_id.id, 'clinic_ids': invitation.clinic_ids.ids, 'expires_at': invitation.expires_at.isoformat()})

    @http.route('/medibook/api/registration/invitation/<string:token>/accept', type='http', auth='none', methods=['POST'], csrf=False)
    def accept_invitation(self, token, **kw):
        body=self._body(); invitation=request.env['medibook.invitation'].sudo().search([('token','=',token)],limit=1)
        if not invitation or invitation.accepted_at: return self._error('invitation_already_used',409)
        if invitation.expires_at <= fields.Datetime.now(): return self._error('invitation_expired',422)
        if not body.get('password') or len(body['password']) < 8 or not body.get('display_name'): return self._error('invalid_registration',422)
        if request.env['res.users'].sudo().search_count([('login','=',invitation.email)]): return self._error('email_already_in_use',409)
        group_ref={'doctor':'medibook_base.group_medibook_doctor','receptionist':'medibook_base.group_medibook_receptionist','clinicAdmin':'medibook_base.group_medibook_clinic_admin','orgAdmin':'medibook_base.group_medibook_org_admin'}[invitation.role]
        user=request.env['res.users'].sudo().create({'name':body['display_name'],'login':invitation.email,'password':body['password'],'company_id':request.env.company.id,'company_ids':[(6,0,[request.env.company.id])],'group_ids':[(6,0,[request.env.ref('base.group_portal').id,request.env.ref(group_ref).id])],'medibook_organization_id':invitation.organization_id.id,'medibook_clinic_ids':[(6,0,invitation.clinic_ids.ids)]})
        invitation.write({'accepted_at':fields.Datetime.now(),'accepted_by_id':user.id})
        return self._json({'user_id':str(user.id),'role':invitation.role},201)

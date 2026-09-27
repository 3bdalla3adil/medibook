from odoo.exceptions import UserError
from odoo.tests.common import TransactionCase

class TestMediBookConsultation(TransactionCase):
    def test_signed_note_is_immutable(self):
        org=self.env["medibook.organization"].create({"name":"Consult Org","code":"CONS-TEST"})
        clinic=self.env["medibook.clinic"].create({"name":"Clinic","code":"CC","organization_id":org.id})
        doctor=self.env["medibook.practitioner"].create({"name":"Doctor","organization_id":org.id})
        patient=self.env["medibook.patient"].create({"name":"Patient","organization_id":org.id})
        service=self.env["medibook.medical.service"].create({"name":"Visit","code":"VIS","organization_id":org.id})
        appt=self.env["medibook.appointment"].create({"name":"A","clinic_id":clinic.id,"patient_id":patient.id,"doctor_id":doctor.id,"service_id":service.id,"starts_at":"2031-01-01 10:00:00"})
        rec=self.env["medibook.consultation"].create({"name":"C","appointment_id":appt.id})
        rec.action_start(); rec.write({"notes":"Initial"}); rec.action_sign()
        with self.assertRaises(UserError): rec.write({"notes":"Changed"})

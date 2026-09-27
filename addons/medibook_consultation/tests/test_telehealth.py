from odoo.tests.common import TransactionCase

class TestMediBookTelehealth(TransactionCase):
    def test_session_token_is_not_copied(self):
        org=self.env["medibook.organization"].create({"name":"TH Org","code":"TH"})
        clinic=self.env["medibook.clinic"].create({"name":"Clinic","code":"THC","organization_id":org.id})
        doctor=self.env["medibook.practitioner"].create({"name":"Doctor","organization_id":org.id})
        patient=self.env["medibook.patient"].create({"name":"Patient","organization_id":org.id})
        service=self.env["medibook.medical.service"].create({"name":"Visit","code":"THV","organization_id":org.id})
        appt=self.env["medibook.appointment"].create({"name":"A","clinic_id":clinic.id,"patient_id":patient.id,"doctor_id":doctor.id,"service_id":service.id,"starts_at":"2033-01-01 10:00:00","is_telehealth":True})
        session=self.env["medibook.telehealth.session"].create({"name":"S","appointment_id":appt.id,"room_id":"room","room_url":"https://example.invalid","join_token":"secret","token_expires_at":"2033-01-01 10:10:00"})
        copy=session.copy()
        self.assertNotEqual(session.join_token,copy.join_token)

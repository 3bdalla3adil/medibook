from odoo.exceptions import UserError
from odoo.tests.common import TransactionCase

class TestMediBookPrescription(TransactionCase):
    def test_issue_requires_active_consultation_and_line(self):
        org=self.env["medibook.organization"].create({"name":"RX Org","code":"RX"})
        clinic=self.env["medibook.clinic"].create({"name":"Clinic","code":"RXC","organization_id":org.id})
        doctor=self.env["medibook.practitioner"].create({"name":"Doctor","organization_id":org.id})
        patient=self.env["medibook.patient"].create({"name":"Patient","organization_id":org.id})
        service=self.env["medibook.medical.service"].create({"name":"Visit","code":"RXV","organization_id":org.id})
        appt=self.env["medibook.appointment"].create({"name":"A","clinic_id":clinic.id,"patient_id":patient.id,"doctor_id":doctor.id,"service_id":service.id,"starts_at":"2032-01-01 10:00:00"})
        consultation=self.env["medibook.consultation"].create({"name":"C","appointment_id":appt.id})
        med=self.env["medibook.medication"].create({"name":"Medication","code":"MED"})
        rx=self.env["medibook.prescription"].create({"name":"RX","consultation_id":consultation.id})
        with self.assertRaises(UserError): rx.action_issue()
        consultation.action_start()
        with self.assertRaises(UserError): rx.action_issue()
        self.env["medibook.prescription.line"].create({"prescription_id":rx.id,"medication_id":med.id,"dosage":"1","frequency":"daily","duration":"5 days"})
        rx.action_issue()
        self.assertEqual(rx.state,"issued")

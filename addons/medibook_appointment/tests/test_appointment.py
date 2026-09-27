from datetime import datetime, timedelta
from odoo.exceptions import ValidationError
from odoo.tests.common import TransactionCase

class TestMediBookAppointment(TransactionCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        cls.org=cls.env["medibook.organization"].create({"name":"Org","code":"APT"})
        cls.clinic=cls.env["medibook.clinic"].create({"name":"Clinic","code":"C","organization_id":cls.org.id})
        cls.doctor=cls.env["medibook.practitioner"].create({"name":"Dr","organization_id":cls.org.id})
        cls.service=cls.env["medibook.medical.service"].create({"name":"Consult","code":"CONS","organization_id":cls.org.id})
        cls.patient=cls.env["medibook.patient"].create({"name":"Patient","organization_id":cls.org.id})
    def test_overlap_is_rejected(self):
        start=datetime(2030,1,1,10,0,0)
        self.env["medibook.appointment"].create({"name":"A1","clinic_id":self.clinic.id,"patient_id":self.patient.id,"doctor_id":self.doctor.id,"service_id":self.service.id,"starts_at":start,"duration_minutes":30})
        with self.assertRaises(ValidationError):
            self.env["medibook.appointment"].create({"name":"A2","clinic_id":self.clinic.id,"patient_id":self.patient.id,"doctor_id":self.doctor.id,"service_id":self.service.id,"starts_at":start+timedelta(minutes=15),"duration_minutes":30})

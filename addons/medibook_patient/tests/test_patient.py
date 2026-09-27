from odoo.tests.common import TransactionCase

class TestMediBookPatient(TransactionCase):
    def test_patient_unique_user(self):
        org=self.env["medibook.organization"].create({"name":"Patient Org","code":"PAT"})
        user=self.env["res.users"].create({"name":"Patient User","login":"patient-test@example.com"})
        Patient=self.env["medibook.patient"]
        Patient.create({"name":"Patient","user_id":user.id,"organization_id":org.id})
        with self.assertRaises(Exception):
            Patient.create({"name":"Duplicate","user_id":user.id,"organization_id":org.id})

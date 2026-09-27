from odoo.exceptions import UserError
from odoo.tests.common import TransactionCase

class TestMedicalRecord(TransactionCase):
    def test_signed_record_is_append_only(self):
        org=self.env["medibook.organization"].create({"name":"MR","code":"MR"})
        patient=self.env["medibook.patient"].create({"name":"Patient","organization_id":org.id})
        rec=self.env["medibook.medical.record"].create({"patient_id":patient.id,"record_type":"note","title":"N","content":"C","recorded_at":"2034-01-01 10:00:00"})
        rec.write({"signed_at":"2034-01-01 10:01:00","signed_by":self.env.user.id})
        with self.assertRaises(UserError): rec.write({"content":"changed"})

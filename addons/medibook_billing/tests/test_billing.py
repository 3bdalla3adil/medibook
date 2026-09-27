from odoo.tests.common import TransactionCase

class TestMediBookBilling(TransactionCase):
    def test_payment_reference_is_unique(self):
        org=self.env["medibook.organization"].create({"name":"Billing Org","code":"BILL"})
        patient=self.env["medibook.patient"].create({"name":"Patient","organization_id":org.id})
        inv=self.env["medibook.invoice"].create({"name":"INV","patient_id":patient.id,"amount_total":100})
        Payment=self.env["medibook.payment"]
        Payment.create({"invoice_id":inv.id,"reference":"PAY-1","provider":"test","provider_payment_token":"token","amount":100})
        with self.assertRaises(Exception):
            Payment.create({"invoice_id":inv.id,"reference":"PAY-1","provider":"test","provider_payment_token":"token2","amount":10})

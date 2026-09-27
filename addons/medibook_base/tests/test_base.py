from odoo.tests.common import TransactionCase

class TestMediBookBase(TransactionCase):
    def test_constraints_are_enforced(self):
        Organization = self.env["medibook.organization"]
        org = Organization.create({"name": "Org", "code": "ORG-1"})
        with self.assertRaises(Exception):
            Organization.create({"name": "Duplicate", "code": "ORG-1"})
        self.assertEqual(org.code, "ORG-1")

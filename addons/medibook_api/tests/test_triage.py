from odoo.tests import TransactionCase, tagged

@tagged("standard", "at_install")
class TestAppointmentTriage(TransactionCase):
    def test_triage_fields_and_defaults(self):
        model = self.env["medibook.appointment"]
        expected = {
            "triage_bp_systolic",
            "triage_bp_diastolic",
            "triage_heart_rate",
            "triage_temperature_c",
            "triage_spo2",
            "triage_weight_kg",
            "triage_height_cm",
            "triage_respiratory_rate",
            "triage_pain_score",
            "triage_note",
            "triage_urgent",
            "triage_recorded",
        }
        self.assertTrue(expected.issubset(model._fields.keys()))
        record = model.new({"name": "Triage test"})
        self.assertFalse(record.triage_urgent)
        self.assertFalse(record.triage_recorded)

    def test_triage_values_are_typed(self):
        record = self.env["medibook.appointment"].new({
            "name": "Triage value test",
            "triage_bp_systolic": 120,
            "triage_bp_diastolic": 80,
            "triage_heart_rate": 72,
            "triage_temperature_c": 36.7,
            "triage_spo2": 98,
            "triage_weight_kg": 70.5,
            "triage_height_cm": 175.0,
            "triage_respiratory_rate": 16,
            "triage_pain_score": 2,
            "triage_note": "Stable",
            "triage_urgent": True,
            "triage_recorded": True,
        })
        self.assertEqual(record.triage_bp_systolic, 120)
        self.assertEqual(record.triage_bp_diastolic, 80)
        self.assertEqual(record.triage_heart_rate, 72)
        self.assertAlmostEqual(record.triage_temperature_c, 36.7)
        self.assertEqual(record.triage_spo2, 98)
        self.assertTrue(record.triage_urgent)
        self.assertTrue(record.triage_recorded)

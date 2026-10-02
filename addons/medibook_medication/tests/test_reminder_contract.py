from pathlib import Path

def test_medication_reminder_cron_runs_every_five_minutes():
    cron = (Path(__file__).parents[1] / 'data' / 'ir_cron.xml').read_text()
    assert '<field name="interval_number">5</field>' in cron
    assert '<field name="interval_type">minutes</field>' in cron

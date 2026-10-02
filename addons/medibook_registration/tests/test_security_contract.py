from pathlib import Path

def test_registration_has_portal_deny_rule():
    rules = Path(__file__).parents[1] / 'security' / 'record_rules.xml'
    text = rules.read_text()
    assert 'invitation_portal_deny' in text
    assert "[(0,'=',1)]" in text

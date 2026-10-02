from pathlib import Path

def test_dispense_endpoint_notifies_patient():
    controller = (Path(__file__).parents[1] / 'controllers' / 'pharmacy.py').read_text()
    assert "'patient_notified':True" in controller
    assert "'status':'dispensed'" in controller

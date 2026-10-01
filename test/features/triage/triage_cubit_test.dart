import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/triage/data/repositories/triage_demo_repository.dart';
import 'package:medibook/features/triage/domain/entities/triage_vitals.dart';
import 'package:medibook/features/triage/presentation/bloc/triage_cubit.dart';

void main(){
  test('loads and saves triage vitals without throwing',() async{
    final cubit=TriageCubit(DemoTriageRepository(),'appointment-1');
    await cubit.load();
    expect(cubit.state.status,TriageStatus.ready);
    final saved=await cubit.save(const TriageVitals(bloodPressureSystolic:120,bloodPressureDiastolic:80,heartRate:72,temperatureC:36.7,spo2:98,painScore:2));
    expect(saved,isTrue);
    expect(cubit.state.vitals?.heartRate,72);
    await cubit.close();
  });
}

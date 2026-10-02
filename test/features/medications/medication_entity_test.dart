import 'package:flutter_test/flutter_test.dart';
import 'package:medibook/features/medications/domain/entities/medication.dart';
void main(){test('medication schedule remains immutable and comparable',(){const a=MedicationSchedule(timeOfDay:480,daysOfWeek:{1,3,5},reminderEnabled:true,reminderLeadMinutes:15);const b=MedicationSchedule(timeOfDay:480,daysOfWeek:{1,3,5},reminderEnabled:true,reminderLeadMinutes:15);expect(a,b);});}

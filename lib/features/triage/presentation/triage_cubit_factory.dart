import 'bloc/triage_cubit.dart';
import '../../../../core/di/injector.dart';

typedef TriageCubitFactory = TriageCubit Function(String appointmentId);
TriageCubit buildTriageCubit(String appointmentId)=>TriageCubit(getIt(),appointmentId);

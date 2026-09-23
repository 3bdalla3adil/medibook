import '../../features/appointments/data/datasources/appointment_local_data_source.dart';
import '../../features/appointments/data/datasources/appointment_remote_data_source.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/data/repositories/booking_repository_impl.dart';
import '../../features/appointments/domain/repositories/appointment_repository.dart';
import '../../features/appointments/domain/repositories/booking_repository.dart';
import '../../features/appointments/domain/usecases/cancel_appointment.dart';
import '../../features/appointments/domain/usecases/get_appointment.dart';
import '../../features/appointments/domain/usecases/get_appointments.dart';
import '../../features/appointments/domain/usecases/get_upcoming_appointment.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/demo_auth_remote_data_source.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/restore_session.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/patients/data/datasources/patient_remote_data_source.dart';
import '../../features/patients/data/repositories/patient_repository_impl.dart';
import '../../features/patients/domain/repositories/patient_repository.dart';
import '../../features/patients/domain/usecases/get_patient_profile.dart';
import '../../features/telehealth/data/repositories/telehealth_repository_impl.dart';
import '../../features/telehealth/domain/repositories/telehealth_repository.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../storage/local_store.dart';
import '../sync/sync_engine.dart';
import 'injector.dart';

Future<void> registerFeatures() async {
  final dio = getIt<DioClient>().dio;
  final store = getIt<LocalStore>();
  final sync = getIt<SyncEngine>();

  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () {
        final config = getIt<AppConfig>();
        if (config.enableDemoAuth) {
          return DemoAuthRemoteDataSource(
            firebase: config.enableFirebaseAuth
                ? FirebaseAuthRemoteDataSource()
                : null,
          );
        }
        if (config.enableFirebaseAuth) {
          return FirebaseAuthRemoteDataSource();
        }
        return DioAuthRemoteDataSource(dio);
      },
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => SecureAuthLocalDataSource(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        store: store,
      ),
    )
    ..registerFactory(() => LoginUseCase(getIt()))
    ..registerFactory(() => RegisterUseCase(getIt()))
    ..registerFactory(() => LogoutUseCase(getIt()))
    ..registerFactory(() => RestoreSessionUseCase(getIt()))
    ..registerFactory(
      () => AuthBloc(
        login: getIt(),
        register: getIt(),
        logout: getIt(),
        restore: getIt(),
        repository: getIt(),
      ),
    );

  getIt
    ..registerLazySingleton<AppointmentRemoteDataSource>(
      () => DioAppointmentRemoteDataSource(dio),
    )
    ..registerLazySingleton<AppointmentLocalDataSource>(
      () => HiveAppointmentLocalDataSource(store),
    )
    ..registerLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        sync: sync,
        networkInfo: getIt(),
        clock: getIt(),
      ),
    )
    ..registerFactory(() => GetAppointmentUseCase(getIt()))
    ..registerFactory(() => GetAppointmentsUseCase(getIt()))
    ..registerFactory(() => GetUpcomingAppointmentUseCase(getIt()))
    ..registerFactory(() => CancelAppointmentUseCase(getIt()))
    ..registerLazySingleton<BookingRepository>(() => DioBookingRepository(dio));

  getIt
    ..registerLazySingleton<PatientRemoteDataSource>(
      () => DioPatientRemoteDataSource(dio),
    )
    ..registerLazySingleton<PatientRepository>(
      () => PatientRepositoryImpl(remote: getIt(), local: store),
    )
    ..registerFactory(() => GetPatientProfileUseCase(getIt()));

  getIt.registerLazySingleton<TelehealthRepository>(
    () => DioTelehealthRepository(dio),
  );

  getIt.registerFactory(
    () => DashboardBloc(
      getProfile: getIt(),
      getAppointments: getIt(),
      getUpcoming: getIt(),
      appointmentRepository: getIt(),
      networkInfo: getIt(),
      clock: getIt(),
    ),
  );
}

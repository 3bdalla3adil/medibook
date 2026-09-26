import '../../features/appointments/data/datasources/appointment_demo_data_source.dart';
import '../../features/appointments/data/datasources/appointment_local_data_source.dart';
import '../../features/appointments/data/datasources/appointment_remote_data_source.dart';
import '../../features/appointments/data/repositories/appointment_demo_repository.dart';
import '../../features/appointments/data/repositories/appointment_repository_impl.dart';
import '../../features/appointments/data/repositories/booking_demo_repository.dart';
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
import '../../features/auth/data/repositories/demo_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/restore_session.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/clinics/data/datasources/clinic_demo_data_source.dart';
import '../../features/clinics/data/datasources/clinic_remote_data_source.dart';
import '../../features/clinics/data/repositories/clinic_repository_impl.dart';
import '../../features/clinics/domain/repositories/clinic_repository.dart';
import '../../features/clinics/domain/usecases/get_clinics.dart';
import '../../features/clinics/presentation/bloc/clinic_list_cubit.dart';
import '../../features/consultations/data/datasources/consultation_demo_data_source.dart';
import '../../features/consultations/data/datasources/consultation_remote_data_source.dart';
import '../../features/consultations/data/repositories/consultation_repository_impl.dart';
import '../../features/consultations/domain/repositories/consultation_repository.dart';
import '../../features/consultations/domain/usecases/get_consultations.dart';
import '../../features/consultations/presentation/bloc/consultation_list_cubit.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/doctors/data/datasources/doctor_demo_data_source.dart';
import '../../features/doctors/data/datasources/doctor_remote_data_source.dart';
import '../../features/doctors/data/repositories/doctor_repository_impl.dart';
import '../../features/doctors/domain/repositories/doctor_repository.dart';
import '../../features/doctors/domain/usecases/get_doctors.dart';
import '../../features/doctors/presentation/bloc/doctor_list_cubit.dart';
import '../../features/medical_records/data/datasources/medical_record_demo_data_source.dart';
import '../../features/medical_records/data/datasources/medical_record_remote_data_source.dart';
import '../../features/medical_records/data/repositories/medical_record_repository_impl.dart';
import '../../features/medical_records/domain/repositories/medical_record_repository.dart';
import '../../features/medical_records/domain/usecases/get_medical_record.dart';
import '../../features/medical_records/presentation/bloc/medical_record_cubit.dart';
import '../../features/patients/data/datasources/patient_demo_data_source.dart';
import '../../features/patients/data/datasources/patient_directory_demo_data_source.dart';
import '../../features/patients/data/datasources/patient_directory_remote_data_source.dart';
import '../../features/patients/data/datasources/patient_remote_data_source.dart';
import '../../features/patients/data/repositories/demo_patient_repository.dart';
import '../../features/patients/data/repositories/patient_directory_repository_impl.dart';
import '../../features/patients/data/repositories/patient_repository_impl.dart';
import '../../features/patients/domain/repositories/patient_directory_repository.dart';
import '../../features/patients/domain/repositories/patient_repository.dart';
import '../../features/patients/domain/usecases/get_patient_directory.dart';
import '../../features/patients/domain/usecases/get_patient_profile.dart';
import '../../features/patients/presentation/bloc/patient_directory_cubit.dart';
import '../../features/prescriptions/data/datasources/prescription_demo_data_source.dart';
import '../../features/prescriptions/data/datasources/prescription_remote_data_source.dart';
import '../../features/prescriptions/data/repositories/prescription_repository_impl.dart';
import '../../features/prescriptions/domain/repositories/prescription_repository.dart';
import '../../features/prescriptions/domain/usecases/get_prescriptions.dart';
import '../../features/prescriptions/presentation/bloc/prescription_list_cubit.dart';
import '../../features/services/data/datasources/service_demo_data_source.dart';
import '../../features/services/data/datasources/service_remote_data_source.dart';
import '../../features/services/data/repositories/service_repository_impl.dart';
import '../../features/services/domain/repositories/service_repository.dart';
import '../../features/services/domain/usecases/get_services.dart';
import '../../features/services/presentation/bloc/service_list_cubit.dart';
import '../../features/telehealth/data/repositories/daily_call_service_impl.dart';
import '../../features/telehealth/data/repositories/daily_telehealth_repository.dart';
import '../../features/telehealth/data/repositories/demo_call_service.dart';
import '../../features/telehealth/data/repositories/telehealth_demo_repository.dart';
import '../../features/telehealth/domain/repositories/daily_call_service.dart';
import '../../features/telehealth/domain/repositories/telehealth_repository.dart';
import '../../features/telehealth/presentation/bloc/telehealth_session_bloc.dart';
import '../config/app_config.dart';
import '../network/dio_client.dart';
import '../security/session_expiry_signal.dart';
import '../storage/local_store.dart';
import '../sync/sync_engine.dart';
import 'injector.dart';

Future<void> registerFeatures() async {
  final dio = getIt<DioClient>().dio;
  final store = getIt<LocalStore>();
  final sync = getIt<SyncEngine>();

  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(() {
      final config = getIt<AppConfig>();
      if (config.enableDemoAuth) {
        return DemoAuthRemoteDataSource(
          firebase: config.enableFirebaseAuth ? FirebaseAuthRemoteDataSource() : null,
        );
      }
      if (config.enableFirebaseAuth) return FirebaseAuthRemoteDataSource();
      return DioAuthRemoteDataSource(dio);
    })
    ..registerLazySingleton<AuthLocalDataSource>(() => SecureAuthLocalDataSource(getIt()))
    ..registerLazySingleton<AuthRepository>(() {
      final config = getIt<AppConfig>();
      if (config.enableDemoAuth) {
        return DemoAuthRepository(getIt<AuthRemoteDataSource>());
      }
      return AuthRepositoryImpl(remote: getIt(), local: getIt(), store: store);
    })
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
        sessionExpirySignal: getIt<SessionExpirySignal>(),
      ),
    )
    ..registerLazySingleton<AppointmentRemoteDataSource>(() {
      return getIt<AppConfig>().enableDemoAuth
          ? const DemoAppointmentRemoteDataSource()
          : DioAppointmentRemoteDataSource(dio);
    })
    ..registerLazySingleton<AppointmentLocalDataSource>(() => HiveAppointmentLocalDataSource(store))
    ..registerLazySingleton<AppointmentRepository>(() {
      if (getIt<AppConfig>().enableDemoAuth) {
        return DemoAppointmentRepository(getIt());
      }
      return AppointmentRepositoryImpl(
        remote: getIt(),
        local: getIt(),
        sync: sync,
        networkInfo: getIt(),
        clock: getIt(),
      );
    })
    ..registerFactory(() => GetAppointmentUseCase(getIt()))
    ..registerFactory(() => GetAppointmentsUseCase(getIt()))
    ..registerFactory(() => GetUpcomingAppointmentUseCase(getIt()))
    ..registerFactory(() => CancelAppointmentUseCase(getIt()))
    ..registerLazySingleton<BookingRepository>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoBookingRepository()
          : DioBookingRepository(dio),
    )
    ..registerLazySingleton<PatientRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoPatientRemoteDataSource()
          : DioPatientRemoteDataSource(dio),
    )
    ..registerLazySingleton<PatientRepository>(() {
      if (getIt<AppConfig>().enableDemoAuth) return const DemoPatientRepository();
      return PatientRepositoryImpl(remote: getIt(), local: store);
    })
    ..registerFactory(() => GetPatientProfileUseCase(getIt()))
    ..registerLazySingleton<PatientDirectoryRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoPatientDirectoryRemoteDataSource()
          : DioPatientDirectoryRemoteDataSource(dio),
    )
    ..registerLazySingleton<PatientDirectoryRepository>(
      () => PatientDirectoryRepositoryImpl(getIt()),
    )
    ..registerFactory(() => GetPatientDirectoryUseCase(getIt()))
    ..registerFactory(() => PatientDirectoryCubit(getIt()))
    ..registerLazySingleton<ClinicRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoClinicRemoteDataSource()
          : DioClinicRemoteDataSource(dio),
    )
    ..registerLazySingleton<ClinicRepository>(() => ClinicRepositoryImpl(getIt()))
    ..registerFactory(() => GetClinicsUseCase(getIt()))
    ..registerFactory(() => ClinicListCubit(getIt()))
    ..registerLazySingleton<ServiceRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoServiceRemoteDataSource()
          : DioServiceRemoteDataSource(dio),
    )
    ..registerLazySingleton<ServiceRepository>(() => ServiceRepositoryImpl(getIt()))
    ..registerFactory(() => GetServicesUseCase(getIt()))
    ..registerFactory(() => ServiceListCubit(getIt()))
    ..registerLazySingleton<DoctorRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoDoctorRemoteDataSource()
          : DioDoctorRemoteDataSource(dio),
    )
    ..registerLazySingleton<DoctorRepository>(() => DoctorRepositoryImpl(getIt()))
    ..registerFactory(() => GetDoctorsUseCase(getIt()))
    ..registerFactory(() => DoctorListCubit(getIt()))
    ..registerLazySingleton<MedicalRecordRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoMedicalRecordRemoteDataSource()
          : DioMedicalRecordRemoteDataSource(dio),
    )
    ..registerLazySingleton<MedicalRecordRepository>(
      () => MedicalRecordRepositoryImpl(getIt()),
    )
    ..registerFactory(() => GetMedicalRecordUseCase(getIt()))
    ..registerFactory(() => MedicalRecordCubit(getIt()))
    ..registerLazySingleton<ConsultationRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoConsultationRemoteDataSource()
          : DioConsultationRemoteDataSource(dio),
    )
    ..registerLazySingleton<ConsultationRepository>(
      () => ConsultationRepositoryImpl(getIt()),
    )
    ..registerFactory(() => GetConsultationsUseCase(getIt()))
    ..registerFactory(() => ConsultationListCubit(getIt()))
    ..registerLazySingleton<PrescriptionRemoteDataSource>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoPrescriptionRemoteDataSource()
          : DioPrescriptionRemoteDataSource(dio),
    )
    ..registerLazySingleton<PrescriptionRepository>(
      () => PrescriptionRepositoryImpl(getIt()),
    )
    ..registerFactory(() => GetPrescriptionsUseCase(getIt()))
    ..registerFactory(() => PrescriptionListCubit(getIt()))
    ..registerLazySingleton<TelehealthRepository>(
      () => getIt<AppConfig>().enableDemoAuth
          ? const DemoTelehealthRepository()
          : DailyTelehealthRepository(dio),
    )
    ..registerLazySingleton<DailyCallService>(
      () => getIt<AppConfig>().enableDemoAuth
          ? DemoCallService()
          : DailyCallServiceImpl(),
    )
    ..registerFactory(
      () => TelehealthSessionBloc(
        repository: getIt(),
        callService: getIt(),
        consultations: getIt(),
        screenGuard: getIt(),
        clock: getIt(),
      ),
    )
    ..registerFactory(
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

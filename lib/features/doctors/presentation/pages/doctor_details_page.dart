import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/result.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/usecases/get_doctor.dart';

class DoctorDetailsPage extends StatelessWidget {
  const DoctorDetailsPage({required this.doctorId, super.key});

  final String doctorId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => _DoctorDetailsCubit(getIt<GetDoctorUseCase>())..load(doctorId),
        child: const _DoctorDetailsView(),
      );
}

class _DoctorDetailsCubit extends Cubit<_DoctorDetailsState> {
  _DoctorDetailsCubit(this._getDoctor) : super(const _DoctorDetailsState.loading());

  final GetDoctorUseCase _getDoctor;

  Future<void> load(String id) async {
    emit(const _DoctorDetailsState.loading());
    final result = await _getDoctor(id);
    switch (result) {
      case Ok(value: final doctor):
        if (doctor == null) {
          emit(const _DoctorDetailsState.error());
        } else {
          emit(_DoctorDetailsState.ready(doctor));
        }
      case Err():
        emit(const _DoctorDetailsState.error());
    }
  }
}

sealed class _DoctorDetailsState {
  const _DoctorDetailsState();
  const factory _DoctorDetailsState.loading() = _DoctorDetailsLoading;
  const factory _DoctorDetailsState.ready(Doctor doctor) = _DoctorDetailsReady;
  const factory _DoctorDetailsState.error() = _DoctorDetailsError;
}

class _DoctorDetailsLoading extends _DoctorDetailsState {
  const _DoctorDetailsLoading();
}

class _DoctorDetailsReady extends _DoctorDetailsState {
  const _DoctorDetailsReady(this.doctor);
  final Doctor doctor;
}

class _DoctorDetailsError extends _DoctorDetailsState {
  const _DoctorDetailsError();
}

class _DoctorDetailsView extends StatelessWidget {
  const _DoctorDetailsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorDetailsTitle)),
      body: BlocBuilder<_DoctorDetailsCubit, _DoctorDetailsState>(
        builder: (context, state) {
          if (state is _DoctorDetailsLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state is _DoctorDetailsError) {
            return Center(child: Text(l10n.doctorDetailsUnavailable));
          }

          final doctor = (state as _DoctorDetailsReady).doctor;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: doctor.avatarUrl == null
                      ? null
                      : NetworkImage(doctor.avatarUrl!),
                  child: doctor.avatarUrl == null
                      ? const Icon(Icons.person_outline, size: 48)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                doctor.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (doctor.specialization?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  doctor.specialization!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (doctor.bio?.isNotEmpty == true) ...[
                const SizedBox(height: 24),
                Text(doctor.bio!),
              ],
              if (doctor.languages.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.doctorLanguages,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: doctor.languages.map((language) => Chip(label: Text(language))).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

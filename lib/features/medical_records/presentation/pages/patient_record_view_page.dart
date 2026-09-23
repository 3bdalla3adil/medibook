import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/medical_record_cubit.dart';

class PatientRecordViewPage extends StatelessWidget {
  const PatientRecordViewPage({super.key, required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<MedicalRecordCubit>()..load(patientId),
        child: _RecordView(patientId: patientId),
      );
}

class _RecordView extends StatelessWidget {
  const _RecordView({required this.patientId});
  final String patientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.medicalRecordsTitle)),
      body: BlocBuilder<MedicalRecordCubit, MedicalRecordState>(
        builder: (context, state) {
          if (state.status == MedicalRecordStatus.loading && state.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == MedicalRecordStatus.error && state.entries.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<MedicalRecordCubit>().load(patientId),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.entries.isEmpty) {
            return Center(child: Text(l10n.medicalRecordsEmpty));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final entry = state.entries[index];
              return Card(
                child: ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.body),
                  isThreeLine: true,
                  trailing: Text(
                    MaterialLocalizations.of(context).formatShortDate(entry.createdAt),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

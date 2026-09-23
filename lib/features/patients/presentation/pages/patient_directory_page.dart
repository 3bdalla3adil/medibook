import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/patient_directory_cubit.dart';

class PatientDirectoryPage extends StatelessWidget {
  const PatientDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<PatientDirectoryCubit>()..load(),
        child: const _PatientDirectoryView(),
      );
}

class _PatientDirectoryView extends StatelessWidget {
  const _PatientDirectoryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.patientsTitle)),
      body: BlocBuilder<PatientDirectoryCubit, PatientDirectoryState>(
        builder: (context, state) {
          if (state.status == PatientDirectoryStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == PatientDirectoryStatus.error && state.items.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<PatientDirectoryCubit>().load(),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.items.isEmpty) return Center(child: Text(l10n.patientsEmpty));
          return RefreshIndicator(
            onRefresh: context.read<PatientDirectoryCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(state.items[index].displayName),
                  subtitle: Text(
                    state.items[index].lastVisit == null
                        ? l10n.patientNoLastVisit
                        : l10n.patientLastVisit(
                            MaterialLocalizations.of(context).formatFullDate(
                              state.items[index].lastVisit!,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

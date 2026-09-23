import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/doctor_list_cubit.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<DoctorListCubit>()..load(),
        child: const _DoctorListView(),
      );
}

class _DoctorListView extends StatelessWidget {
  const _DoctorListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.doctorsTitle)),
      body: BlocBuilder<DoctorListCubit, DoctorListState>(
        builder: (context, state) {
          if (state.status == DoctorListStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == DoctorListStatus.error && state.items.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<DoctorListCubit>().load(),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.items.isEmpty) return Center(child: Text(l10n.doctorsEmpty));
          return RefreshIndicator(
            onRefresh: context.read<DoctorListCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final doctor = state.items[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: doctor.avatarUrl == null
                          ? null
                          : NetworkImage(doctor.avatarUrl!),
                      child: doctor.avatarUrl == null
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    title: Text(doctor.displayName),
                    subtitle: Text(doctor.specialization),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

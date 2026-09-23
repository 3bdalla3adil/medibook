import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/prescription_list_cubit.dart';

class PrescriptionListPage extends StatelessWidget {
  const PrescriptionListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<PrescriptionListCubit>()..load(),
        child: const _PrescriptionListView(),
      );
}

class _PrescriptionListView extends StatelessWidget {
  const _PrescriptionListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.prescriptionsTitle)),
      body: BlocBuilder<PrescriptionListCubit, PrescriptionListState>(
        builder: (context, state) {
          if (state.status == PrescriptionListStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == PrescriptionListStatus.error && state.items.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<PrescriptionListCubit>().load(),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.items.isEmpty) return Center(child: Text(l10n.prescriptionsEmpty));
          return RefreshIndicator(
            onRefresh: context.read<PrescriptionListCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = state.items[index];
                return Card(
                  child: ExpansionTile(
                    title: Text(item.status.name),
                    subtitle: Text(
                      MaterialLocalizations.of(context).formatShortDate(item.issuedAt),
                    ),
                    children: [
                      for (final medication in item.items)
                        ListTile(
                          title: Text(medication.medicationName),
                          subtitle: Text(
                            '${medication.dose} • ${medication.frequency}',
                          ),
                        ),
                    ],
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

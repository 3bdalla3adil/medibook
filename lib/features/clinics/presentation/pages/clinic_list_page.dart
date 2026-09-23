import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/clinic_list_cubit.dart';

class ClinicListPage extends StatelessWidget {
  const ClinicListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ClinicListCubit>()..load(),
      child: const _ClinicListView(),
    );
  }
}

class _ClinicListView extends StatelessWidget {
  const _ClinicListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.clinicsTitle)),
      body: BlocBuilder<ClinicListCubit, ClinicListState>(
        builder: (context, state) {
          if (state.status == ClinicListStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == ClinicListStatus.error && state.items.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<ClinicListCubit>().load(),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.items.isEmpty) return Center(child: Text(l10n.clinicsEmpty));

          return RefreshIndicator(
            onRefresh: context.read<ClinicListCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final clinic = state.items[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      clinic.localizedName(
                        Localizations.localeOf(context).languageCode,
                      ),
                    ),
                    subtitle: Text('${clinic.address}\n${clinic.phone}'),
                    isThreeLine: true,
                    trailing: Icon(
                      clinic.isActive
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                    ),
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

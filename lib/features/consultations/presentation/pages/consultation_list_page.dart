import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/consultation_list_cubit.dart';

class ConsultationListPage extends StatelessWidget {
  const ConsultationListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<ConsultationListCubit>()..load(),
        child: const _ConsultationListView(),
      );
}

class _ConsultationListView extends StatelessWidget {
  const _ConsultationListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.consultationsTitle)),
      body: BlocBuilder<ConsultationListCubit, ConsultationListState>(
        builder: (context, state) {
          if (state.status == ConsultationListStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == ConsultationListStatus.error && state.items.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<ConsultationListCubit>().load(),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.items.isEmpty) return Center(child: Text(l10n.consultationsEmpty));
          return RefreshIndicator(
            onRefresh: context.read<ConsultationListCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = state.items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.diagnosis ?? l10n.consultationWithoutDiagnosis),
                    subtitle: Text(item.note ?? ''),
                    trailing: Text(item.status.name),
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

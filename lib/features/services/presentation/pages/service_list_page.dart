import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/service_list_cubit.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => getIt<ServiceListCubit>()..load(),
        child: const _ServiceListView(),
      );
}

class _ServiceListView extends StatelessWidget {
  const _ServiceListView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.servicesTitle)),
      body: BlocBuilder<ServiceListCubit, ServiceListState>(
        builder: (context, state) {
          if (state.status == ServiceListStatus.loading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.status == ServiceListStatus.error && state.items.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<ServiceListCubit>().load(),
                child: Text(l10n.actionRetry),
              ),
            );
          }
          if (state.items.isEmpty) return Center(child: Text(l10n.servicesEmpty));
          return RefreshIndicator(
            onRefresh: context.read<ServiceListCubit>().load,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final service = state.items[index];
                return Card(
                  child: ListTile(
                    title: Text(service.name),
                    subtitle: Text(
                      service.description.isEmpty
                          ? l10n.serviceDuration(service.durationMinutes)
                          : service.description,
                    ),
                    trailing: Text(
                      service.price.toStringAsFixed(2) + ' ' + service.currency,
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

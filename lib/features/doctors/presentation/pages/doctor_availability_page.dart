import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/availability_slot.dart';
import '../bloc/doctor_availability_bloc.dart';

class DoctorAvailabilityPage extends StatelessWidget {
  const DoctorAvailabilityPage({
    super.key,
    required this.doctorId,
    required this.clinicId,
    required this.serviceId,
    this.onSlotSelected,
  });

  final String doctorId;
  final String clinicId;
  final String serviceId;
  final void Function(AvailabilitySlot)? onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DoctorAvailabilityBloc(
        getAvailability: context.read(),
      )..add(DoctorAvailabilityRequested(
          doctorId: doctorId,
          clinicId: clinicId,
          serviceId: serviceId,
          date: DateTime.now(),
        )),
      child: _DoctorAvailabilityView(onSlotSelected: onSlotSelected),
    );
  }
}

class _DoctorAvailabilityView extends StatelessWidget {
  const _DoctorAvailabilityView({this.onSlotSelected});
  final void Function(AvailabilitySlot)? onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.availabilityTitle)),
      body: BlocBuilder<DoctorAvailabilityBloc, DoctorAvailabilityState>(
        builder: (context, state) {
          return Column(
            children: [
              _DateSelector(
                selected: state.selectedDate ?? DateTime.now(),
                onChanged: (d) => context
                    .read<DoctorAvailabilityBloc>()
                    .add(DoctorAvailabilityDateChanged(d)),
              ),
              Expanded(child: _buildBody(context, state, l10n)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DoctorAvailabilityState state,
    AppLocalizations l10n,
  ) {
    switch (state.status) {
      case DoctorAvailabilityStatus.idle:
      case DoctorAvailabilityStatus.loading:
        return const LoadingView();
      case DoctorAvailabilityStatus.error:
        return ErrorView(
          message: l10n.errorGeneric,
          onRetry: () {
            final bloc = context.read<DoctorAvailabilityBloc>();
            final date = state.selectedDate;
            if (date == null) return;
            bloc.add(DoctorAvailabilityRequested(
              doctorId: state.doctorId!,
              clinicId: state.clinicId!,
              serviceId: state.serviceId!,
              date: date,
            ));
          },
        );
      case DoctorAvailabilityStatus.ready:
        if (state.slots.isEmpty) {
          return EmptyView(
            title: l10n.availabilityEmptyTitle,
            message: l10n.availabilityEmptyMessage,
            icon: Icons.event_busy_outlined,
          );
        }
        return _SlotGrid(
          slots: state.slots,
          onSelect: onSlotSelected,
        );
    }
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.selected, required this.onChanged});
  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      14,
      (i) => DateTime.now().add(Duration(days: i)),
    );

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
        itemCount: dates.length,
        itemBuilder: (context, i) {
          final d = dates[i];
          final isSelected = d.day == selected.day &&
              d.month == selected.month &&
              d.year == selected.year;
          return Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
            child: ChoiceChip(
              selected: isSelected,
              onSelected: (_) => onChanged(d),
              label: Text('${d.day}/${d.month}'),
            ),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({required this.slots, this.onSelect});
  final List<AvailabilitySlot> slots;
  final void Function(AvailabilitySlot)? onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsetsDirectional.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, i) {
        final slot = slots[i];
        final local = slot.startsAt.toLocal();
        final label =
            '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
        return OutlinedButton(
          onPressed:
              slot.isBookable && onSelect != null ? () => onSelect!(slot) : null,
          child: Text(label),
        );
      },
    );
  }
}

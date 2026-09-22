import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/clock.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../patients/domain/usecases/get_patient_profile.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/entities/booking_option.dart';
import '../../domain/entities/booking_slot.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/appointment_repository.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});
  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  BookingOption? clinic, service, doctor;
  BookingSlot? slot;
  DateTime day = DateTime.now();
  List<BookingOption> clinics = const [], services = const [], doctors = const [];
  List<BookingSlot> slots = const [];
  bool loading = true, submitting = false;
  String? error;

  BookingRepository get booking => getIt<BookingRepository>();
  AppointmentRepository get appointments => getIt<AppointmentRepository>();

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    setState(() { loading = true; error = null; });
    final result = await booking.getClinics();
    if (!mounted) return;
    setState(() { clinics = result.valueOrNull ?? const []; loading = false; });
  }

  Future<void> _selectClinic(BookingOption? value) async {
    setState(() { clinic = value; service = null; doctor = null; slot = null; services = []; doctors = []; slots = []; });
    if (value == null) return;
    final result = await booking.getServices(value.id);
    if (mounted) setState(() => services = result.valueOrNull ?? const []);
  }

  Future<void> _selectService(BookingOption? value) async {
    setState(() { service = value; doctor = null; slot = null; doctors = []; slots = []; });
    if (value == null || clinic == null) return;
    final result = await booking.getDoctors(clinicId: clinic!.id, serviceId: value.id);
    if (mounted) setState(() => doctors = result.valueOrNull ?? const []);
  }

  Future<void> _loadSlots() async {
    if (clinic == null || service == null || doctor == null) return;
    final result = await booking.getAvailableSlots(
      clinicId: clinic!.id, serviceId: service!.id, doctorId: doctor!.id, day: day,
    );
    if (mounted) setState(() { slots = result.valueOrNull ?? const []; slot = null; });
  }

  Future<void> _submit() async {
    if (clinic == null || service == null || doctor == null || slot == null) return;
    setState(() { submitting = true; error = null; });
    final profile = await getIt<GetPatientProfileUseCase>()();
    final patient = profile.valueOrNull;
    if (patient == null) {
      if (mounted) setState(() { submitting = false; error = 'Patient profile is unavailable.'; });
      return;
    }
    final now = getIt<Clock>().now();
    final appointment = Appointment(
      id: const Uuid().v4(),
      clinicId: clinic!.id,
      clinicName: clinic!.name,
      patientId: patient.id,
      doctorId: doctor!.id,
      doctorName: doctor!.name,
      serviceId: service!.id,
      serviceName: service!.name,
      startsAt: slot!.startsAt,
      duration: slot!.duration,
      status: AppointmentStatus.scheduled,
      isTelehealth: false,
      createdAt: now,
      updatedAt: now,
    );
    final result = await appointments.createAppointment(appointment);
    if (!mounted) return;
    if (result.valueOrNull != null) {
      context.go(Routes.appointmentDetails(appointment.id));
    } else {
      setState(() { submitting = false; error = AppLocalizations.of(context).errorGeneric; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMMMMd(locale);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.actionBookAppointment)),
      body: loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Dropdown(label: 'Clinic', value: clinic, items: clinics, onChanged: _selectClinic),
                const SizedBox(height: 16),
                _Dropdown(label: 'Service', value: service, items: services, onChanged: clinic == null ? null : _selectService),
                const SizedBox(height: 16),
                _Dropdown(label: 'Doctor', value: doctor, items: doctors, onChanged: service == null ? null : (v) async {
                  setState(() { doctor = v; slot = null; slots = []; });
                  await _loadSlots();
                }),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(date.format(day)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_month_outlined),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: day,
                      );
                      if (picked != null) { setState(() => day = picked); await _loadSlots(); }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text('Available times', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    for (final item in slots)
                      ChoiceChip(
                        label: Text(DateFormat.jm(locale).format(item.startsAt.toLocal())),
                        selected: slot == item,
                        onSelected: (_) => setState(() => slot = item),
                      ),
                  ],
                ),
                if (slots.isEmpty && doctor != null)
                  const Padding(padding: EdgeInsets.only(top: 16), child: Text('No available slots for this date.')),
                if (error != null)
                  Padding(padding: const EdgeInsets.only(top: 16), child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: submitting || slot == null ? null : _submit,
                  icon: submitting ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.event_available),
                  label: Text(l10n.actionBookAppointment),
                ),
              ],
            ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});
  final String label;
  final BookingOption? value;
  final List<BookingOption> items;
  final ValueChanged<BookingOption?>? onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<BookingOption>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    items: [for (final item in items) DropdownMenuItem(value: item, child: Text(item.name))],
    onChanged: onChanged,
  );
}

import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/domain/entities/auth_user.dart';

enum DemoWorkspace {
  appointments,
  booking,
  records,
  services,
  telehealth,
  patients,
  consultations,
  prescriptions,
  doctors,
  clinics,
  billing,
}

class DemoWorkspacePage extends StatefulWidget {
  const DemoWorkspacePage({
    super.key,
    required this.user,
    required this.workspace,
  });

  final AuthUser user;
  final DemoWorkspace workspace;

  @override
  State<DemoWorkspacePage> createState() => _DemoWorkspacePageState();
}

class _DemoWorkspacePageState extends State<DemoWorkspacePage> {
  int _selectedAppointment = 0;
  bool _cancelled = false;
  bool _completed = false;
  bool _signed = false;
  bool _paid = false;
  String? _selectedDoctor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n, widget.workspace))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoBanner(text: l10n.demoWorkflowReady),
          const SizedBox(height: 16),
          switch (widget.workspace) {
            DemoWorkspace.appointments => _appointments(l10n),
            DemoWorkspace.booking => _booking(l10n),
            DemoWorkspace.records => _records(l10n),
            DemoWorkspace.services => _services(l10n),
            DemoWorkspace.telehealth => _telehealth(l10n),
            DemoWorkspace.patients => _patients(l10n),
            DemoWorkspace.consultations => _consultations(l10n),
            DemoWorkspace.prescriptions => _prescriptions(l10n),
            DemoWorkspace.doctors => _doctors(l10n),
            DemoWorkspace.clinics => _clinics(l10n),
            DemoWorkspace.billing => _billing(l10n),
          },
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n, DemoWorkspace workspace) => switch (workspace) {
        DemoWorkspace.appointments => l10n.dashboardAppointments,
        DemoWorkspace.booking => l10n.actionBookAppointment,
        DemoWorkspace.records => l10n.medicalRecordsTitle,
        DemoWorkspace.services => l10n.servicesTitle,
        DemoWorkspace.telehealth => l10n.telehealthLobbyTitle,
        DemoWorkspace.patients => l10n.patientsTitle,
        DemoWorkspace.consultations => l10n.consultationsTitle,
        DemoWorkspace.prescriptions => l10n.prescriptionsTitle,
        DemoWorkspace.doctors => l10n.doctorsTitle,
        DemoWorkspace.clinics => l10n.clinicsTitle,
        DemoWorkspace.billing => l10n.adminBilling,
      };

  Widget _appointments(AppLocalizations l10n) {
    final appointments = [
      [
        l10n.demoAppointmentOneDoctor,
        l10n.demoAppointmentOneService,
        l10n.demoAppointmentOneDate,
      ],
      [
        l10n.demoAppointmentTwoDoctor,
        l10n.demoAppointmentTwoService,
        l10n.demoAppointmentTwoDate,
      ],
    ];

    return Column(
      children: [
        for (var i = 0; i < appointments.length; i++)
          Card(
            child: ListTile(
              selected: _selectedAppointment == i,
              leading: Icon(
                _cancelled && i == 0
                    ? Icons.event_busy_outlined
                    : Icons.event_available_outlined,
              ),
              title: Text(appointments[i][0]),
              subtitle: Text(
                appointments[i][1] + '\n' + appointments[i][2],
              ),
              isThreeLine: true,
              onTap: () => setState(() => _selectedAppointment = i),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _cancelled
              ? null
              : () => setState(() => _cancelled = true),
          icon: const Icon(Icons.cancel_outlined),
          label: Text(
            _cancelled ? l10n.demoAppointmentCancelled : l10n.demoActionCancel,
          ),
        ),
      ],
    );
  }

  Widget _booking(AppLocalizations l10n) {
    final doctors = [
      l10n.demoDoctorOne,
      l10n.demoDoctorTwo,
      l10n.demoDoctorThree,
    ];
    final times = ['10:00', '11:30', '14:30'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.demoBookLocal, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedDoctor,
          decoration: InputDecoration(labelText: l10n.doctorsTitle),
          items: [
            for (final doctor in doctors)
              DropdownMenuItem(value: doctor, child: Text(doctor)),
          ],
          onChanged: (value) => setState(() => _selectedDoctor = value),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final time in times)
              ChoiceChip(
                label: Text(time),
                selected: false,
                onSelected: _selectedDoctor == null
                    ? null
                    : (_) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.demoAppointmentStatus)),
                        ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _records(AppLocalizations l10n) => Card(
        child: ListTile(
          leading: const Icon(Icons.folder_shared_outlined),
          title: Text(l10n.demoRecordDiagnosis),
          subtitle: Text(
            l10n.demoRecordNote + '\n' + l10n.demoRecordMedication,
          ),
          isThreeLine: true,
        ),
      );

  Widget _services(AppLocalizations l10n) {
    final services = [
      l10n.demoServiceOne,
      l10n.demoServiceTwo,
      l10n.demoServiceThree,
    ];
    return Column(
      children: [
        for (final service in services)
          Card(
            child: ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: Text(service),
              subtitle: Text(l10n.serviceDuration(30)),
            ),
          ),
      ],
    );
  }

  Widget _telehealth(AppLocalizations l10n) => Card(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Icon(Icons.video_call_outlined, size: 64),
            ),
            ListTile(
              title: Text(l10n.telehealthRoom),
              subtitle: Text(l10n.demoWorkflowReady),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.telehealthConnected),
                    content: Text(l10n.demoWorkflowReady),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.actionDetails),
                      ),
                    ],
                  ),
                ),
                icon: const Icon(Icons.video_camera_front_outlined),
                label: Text(l10n.telehealthJoin),
              ),
            ),
          ],
        ),
      );

  Widget _patients(AppLocalizations l10n) {
    final patients = [
      l10n.demoPatientOne,
      l10n.demoPatientTwo,
      l10n.demoPatientThree,
    ];
    return Column(
      children: [
        for (final patient in patients)
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(patient),
              subtitle: Text(l10n.demoPatientDetails),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
      ],
    );
  }

  Widget _consultations(AppLocalizations l10n) {
    final consultations = [
      l10n.demoConsultationOne,
      l10n.demoConsultationTwo,
    ];
    return Column(
      children: [
        for (final consultation in consultations)
          Card(
            child: ListTile(
              leading: const Icon(Icons.assignment_outlined),
              title: Text(consultation),
              subtitle: Text(
                _completed ? l10n.statusCompleted : l10n.statusInConsultation,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _completed ? null : () => setState(() => _completed = true),
          icon: const Icon(Icons.check_circle_outline),
          label: Text(l10n.demoActionComplete),
        ),
      ],
    );
  }

  Widget _prescriptions(AppLocalizations l10n) {
    final prescriptions = [
      l10n.demoPrescriptionOne,
      l10n.demoPrescriptionTwo,
    ];
    return Column(
      children: [
        for (final prescription in prescriptions)
          Card(
            child: ListTile(
              leading: const Icon(Icons.medication_outlined),
              title: Text(prescription),
              subtitle: Text(
                _signed ? l10n.statusCompleted : l10n.statusScheduled,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _signed ? null : () => setState(() => _signed = true),
          icon: const Icon(Icons.draw_outlined),
          label: Text(l10n.demoActionSign),
        ),
      ],
    );
  }

  Widget _doctors(AppLocalizations l10n) {
    final doctors = [
      l10n.demoDoctorOne,
      l10n.demoDoctorTwo,
      l10n.demoDoctorThree,
    ];
    return Column(
      children: [
        for (final doctor in doctors)
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(doctor),
              subtitle: Text(l10n.demoDoctorDetails),
            ),
          ),
      ],
    );
  }

  Widget _clinics(AppLocalizations l10n) {
    final clinics = [l10n.demoClinicOne, l10n.demoClinicTwo];
    return Column(
      children: [
        for (final clinic in clinics)
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital_outlined),
              title: Text(clinic),
              subtitle: Text(l10n.demoClinicDetails),
            ),
          ),
      ],
    );
  }

  Widget _billing(AppLocalizations l10n) => Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text(l10n.demoBillingInvoice),
              subtitle: Text(l10n.demoBillingAmount),
              trailing: Text(
                _paid ? l10n.demoBillingPaid : l10n.statusScheduled,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _paid ? null : () => setState(() => _paid = true),
                icon: const Icon(Icons.payments_outlined),
                label: Text(l10n.demoActionPay),
              ),
            ),
          ],
        ),
      );
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.offline_bolt_outlined),
          title: Text(text),
        ),
      );
}

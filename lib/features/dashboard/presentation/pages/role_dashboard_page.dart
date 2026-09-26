import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class RoleDashboardPage extends StatelessWidget {
  const RoleDashboardPage({super.key, this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? context.read<AuthBloc>().state.user;
    if (currentUser == null) return const _DashboardAuthLoading();

    final role = currentUser.isPatient
        ? _DemoRole.patient
        : currentUser.roles.contains(UserRole.doctor)
            ? _DemoRole.doctor
            : currentUser.roles.contains(UserRole.orgAdmin) ||
                    currentUser.roles.contains(UserRole.clinicAdmin) ||
                    currentUser.roles.contains(UserRole.superAdmin)
                ? _DemoRole.admin
                : null;

    if (role == null) return const _UnknownRoleDashboard();
    return _DemoRoleDashboard(user: currentUser, kind: role);
  }
}

enum _DemoRole { patient, doctor, admin }

class _DemoRoleDashboard extends StatelessWidget {
  const _DemoRoleDashboard({required this.user, required this.kind});

  final AuthUser user;
  final _DemoRole kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = switch (kind) {
      _DemoRole.patient => [
          _WorkflowItem(l10n.actionBookAppointment, Icons.event_available, Routes.bookAppointment),
          _WorkflowItem(l10n.actionSeeAppointments, Icons.calendar_month, Routes.appointments),
          _WorkflowItem(l10n.actionServices, Icons.medical_services_outlined, Routes.services),
          _WorkflowItem(l10n.actionMedicalRecords, Icons.folder_shared_outlined, Routes.medicalRecords),
          _WorkflowItem(l10n.actionTelehealth, Icons.video_call_outlined, Routes.telehealthLobby),
        ],
      _DemoRole.doctor => [
          _WorkflowItem(l10n.doctorSchedule, Icons.calendar_today_outlined, Routes.appointments),
          _WorkflowItem(l10n.doctorPatients, Icons.people_outline, Routes.doctorPatients),
          _WorkflowItem(l10n.doctorConsultations, Icons.assignment_outlined, Routes.consultations),
          _WorkflowItem(l10n.doctorPrescriptions, Icons.medication_outlined, Routes.prescriptions),
          _WorkflowItem(l10n.actionTelehealth, Icons.video_call_outlined, Routes.telehealthLobby),
        ],
      _DemoRole.admin => [
          _WorkflowItem(l10n.adminAppointments, Icons.calendar_month, Routes.appointments),
          _WorkflowItem(l10n.adminPatients, Icons.people_outline, Routes.adminPatients),
          _WorkflowItem(l10n.adminDoctors, Icons.medical_services_outlined, Routes.doctors),
          _WorkflowItem(l10n.adminClinics, Icons.local_hospital_outlined, Routes.clinics),
          _WorkflowItem(l10n.adminBilling, Icons.payments_outlined, Routes.billing),
        ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.actionSignOut,
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardGreeting(user.displayName),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      avatar: Icon(_roleIcon(kind), size: 18),
                      label: Text(_roleLabel(l10n, kind)),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.demoWorkflowDescription),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisExtent: 128,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  return Card(
                    color: _cardColor(index, kind),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => _DemoWorkflowPage(
                            title: item.title,
                            route: item.route,
                            role: kind,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(item.icon, size: 30),
                            const Spacer(),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _cardColor(int index, _DemoRole role) {
    final palette = switch (role) {
      _DemoRole.patient => [
          AppColors.appointmentCard,
          AppColors.patientCard,
          AppColors.servicesCard,
          AppColors.recordsCard,
          AppColors.telehealthCard,
        ],
      _DemoRole.doctor => [
          AppColors.doctorCard,
          AppColors.patientsCard,
          AppColors.consultationCard,
          AppColors.prescriptionCard,
          AppColors.telehealthCard,
        ],
      _DemoRole.admin => [
          AppColors.appointmentCard,
          AppColors.patientsCard,
          AppColors.doctorCard,
          AppColors.adminCard,
          AppColors.servicesCard,
        ],
    };
    return palette[index % palette.length];
  }

  IconData _roleIcon(_DemoRole role) => switch (role) {
        _DemoRole.patient => Icons.person_outline,
        _DemoRole.doctor => Icons.medical_services_outlined,
        _DemoRole.admin => Icons.admin_panel_settings_outlined,
      };

  String _roleLabel(AppLocalizations l10n, _DemoRole role) => switch (role) {
        _DemoRole.patient => l10n.rolePatient,
        _DemoRole.doctor => l10n.roleDoctor,
        _DemoRole.admin => l10n.roleAdmin,
      };
}

class _DemoWorkflowPage extends StatefulWidget {
  const _DemoWorkflowPage({
    required this.title,
    required this.route,
    required this.role,
  });

  final String title;
  final String route;
  final _DemoRole role;

  @override
  State<_DemoWorkflowPage> createState() => _DemoWorkflowPageState();
}

class _DemoWorkflowPageState extends State<_DemoWorkflowPage> {
  bool cancelled = false;
  bool completed = false;
  bool signed = false;
  bool paid = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(_iconFor(widget.route), size: 32),
              title: Text(widget.title),
              subtitle: Text(l10n.demoWorkflowReady),
            ),
          ),
          const SizedBox(height: 12),
          ..._content(context, l10n),
        ],
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppLocalizations l10n) {
    switch (widget.route) {
      case Routes.appointments:
        return [
          _section(l10n.demoAppointmentDetails, [
            _item(l10n.demoAppointmentOneDoctor, l10n.demoAppointmentOneService,
                l10n.demoAppointmentOneDate,
            ),
            _item(l10n.demoAppointmentTwoDoctor, l10n.demoAppointmentTwoService,
                l10n.demoAppointmentTwoDate,
            ),
          ]),
          FilledButton.icon(
            onPressed: cancelled ? null : () => setState(() => cancelled = true),
            icon: const Icon(Icons.cancel_outlined),
            label: Text(
              cancelled ? l10n.demoAppointmentCancelled : l10n.demoActionCancel,
            ),
          ),
        ];
      case Routes.bookAppointment:
        return [
          _section(l10n.demoAppointmentDetails, [
            _item(l10n.demoClinicOne, l10n.demoServiceOne, l10n.demoDoctorOne),
            _item(l10n.demoClinicTwo, l10n.demoServiceTwo, l10n.demoDoctorTwo),
          ]),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.demoAppointmentOneService)),
            ),
            icon: const Icon(Icons.event_available),
            label: Text(l10n.actionBookAppointment),
          ),
        ];
      case Routes.services:
        return [
          _section(l10n.servicesTitle, [
            _item(l10n.demoServiceOne, l10n.serviceDuration(30), l10n.demoClinicOne),
            _item(l10n.demoServiceTwo, l10n.serviceDuration(45), l10n.demoClinicTwo),
            _item(l10n.demoServiceThree, l10n.serviceDuration(30), l10n.demoClinicOne),
          ]),
        ];
      case Routes.medicalRecords:
        return [
          _section(l10n.demoRecordDetails, [
            _item(l10n.demoRecordDiagnosis, l10n.demoRecordMedication, l10n.demoRecordNote,
            ),
          ]),
        ];
      case Routes.telehealthLobby:
        return [
          _section(l10n.telehealthLobbyTitle, [
            _item(l10n.demoAppointmentOneDoctor, l10n.appointmentTelehealth,
                l10n.demoAppointmentOneDate,
            ),
          ]),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.telehealthConnected)),
            ),
            icon: const Icon(Icons.video_call_outlined),
            label: Text(l10n.telehealthJoin),
          ),
        ];
      case Routes.doctorPatients:
      case Routes.adminPatients:
        return [
          _section(l10n.patientsTitle, [
            _item(l10n.demoPatientOne, l10n.patientNoLastVisit, l10n.demoPatientDetails),
            _item(l10n.demoPatientTwo, l10n.patientNoLastVisit, l10n.demoPatientDetails),
            _item(l10n.demoPatientThree, l10n.patientNoLastVisit, l10n.demoPatientDetails),
          ]),
        ];
      case Routes.doctors:
        return [
          _section(l10n.doctorsTitle, [
            _item(l10n.demoDoctorOne, l10n.demoServiceOne, l10n.demoDoctorDetails),
            _item(l10n.demoDoctorTwo, l10n.demoServiceTwo, l10n.demoDoctorDetails),
            _item(l10n.demoDoctorThree, l10n.demoServiceThree, l10n.demoDoctorDetails),
          ]),
        ];
      case Routes.clinics:
        return [
          _section(l10n.clinicsTitle, [
            _item(l10n.demoClinicOne, l10n.demoServiceOne, l10n.demoClinicDetails),
            _item(l10n.demoClinicTwo, l10n.demoServiceTwo, l10n.demoClinicDetails),
          ]),
        ];
      case Routes.consultations:
        return [
          _section(l10n.consultationsTitle, [
            _item(l10n.demoConsultationOne, l10n.demoPatientOne, l10n.demoConsultationDetails),
            _item(l10n.demoConsultationTwo, l10n.demoPatientTwo, l10n.demoConsultationDetails),
          ]),
          FilledButton.icon(
            onPressed: completed ? null : () => setState(() => completed = true),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              completed ? l10n.statusCompleted : l10n.demoActionComplete,
            ),
          ),
        ];
      case Routes.prescriptions:
        return [
          _section(l10n.prescriptionsTitle, [
            _item(l10n.demoPrescriptionOne, l10n.demoPatientOne, l10n.demoPrescriptionDetails),
            _item(l10n.demoPrescriptionTwo, l10n.demoPatientTwo, l10n.demoPrescriptionDetails),
          ]),
          FilledButton.icon(
            onPressed: signed ? null : () => setState(() => signed = true),
            icon: const Icon(Icons.draw_outlined),
            label: Text(
              signed ? l10n.statusCompleted : l10n.demoActionSign,
            ),
          ),
        ];
      case Routes.billing:
        return [
          _section(l10n.adminBilling, [
            _item(l10n.demoBillingInvoice, l10n.demoBillingAmount, l10n.demoBillingPaid,
            ),
          ]),
          FilledButton.icon(
            onPressed: paid ? null : () => setState(() => paid = true),
            icon: const Icon(Icons.payments_outlined),
            label: Text(paid ? l10n.demoBillingPaid : l10n.demoActionPay),
          ),
        ];
      default:
        return [_section(widget.title, [
          _item(widget.title, l10n.demoWorkflowReady, widget.route),
        ]),];
    }
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 12),
        ],
      );

  Widget _item(String title, String subtitle, String detail) => Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.medical_services_outlined)),
          title: Text(title),
          subtitle: Text('$subtitle\n$detail'),
          isThreeLine: true,
        ),
      );

  IconData _iconFor(String route) => switch (route) {
        Routes.appointments => Icons.calendar_month,
        Routes.bookAppointment => Icons.event_available,
        Routes.services => Icons.medical_services_outlined,
        Routes.medicalRecords => Icons.folder_shared_outlined,
        Routes.telehealthLobby => Icons.video_call_outlined,
        Routes.doctorPatients || Routes.adminPatients => Icons.people_outline,
        Routes.doctors => Icons.medical_information_outlined,
        Routes.clinics => Icons.local_hospital_outlined,
        Routes.consultations => Icons.assignment_outlined,
        Routes.prescriptions => Icons.medication_outlined,
        Routes.billing => Icons.payments_outlined,
        _ => Icons.dashboard_outlined,
      };
}

class _DashboardAuthLoading extends StatelessWidget {
  const _DashboardAuthLoading();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).stateLoading),
            ],
          ),
        ),
      );
}

class _UnknownRoleDashboard extends StatelessWidget {
  const _UnknownRoleDashboard();

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        body: Center(child: Text(AppLocalizations.of(context).errorForbidden)),
      );
}

class _WorkflowItem {
  const _WorkflowItem(this.title, this.icon, this.route);
  final String title;
  final IconData icon;
  final String route;
}

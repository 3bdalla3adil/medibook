import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injector.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../data/datasources/demo_auth_remote_data_source.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => const _LoginView();
}

class _LoginView extends StatefulWidget {
  const _LoginView();
  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_localizeError(l10n, state.failure.code))),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthAuthenticating;

            // Make the successful login transition explicit. The router still
            // has the authorization guard, but the auth screen itself should
            // never depend on a timing-sensitive redirect to leave /login.
            if (state is AuthAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && GoRouterState.of(context).uri.path == '/login') {
                  context.go('/');
                }
              });
            }

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.loginTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.loginEmailLabel,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (v) => (v == null || !v.contains('@'))
                              ? l10n.loginEmailInvalid
                              : null,
                          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          enabled: !isLoading,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: l10n.loginPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? l10n.loginPasswordRequired : null,
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                                  )
                                : Text(l10n.actionSignIn),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: isLoading ? null : () => context.push('/register'),
                          child: Text(l10n.actionCreateAccount),
                        ),
                        if (getIt<AppConfig>().enableDemoAuth) ...[
                          const SizedBox(height: 12),
                          _DemoAccountButtons(
                            enabled: !isLoading,
                            onSelect: _useDemoAccount,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _useDemoAccount(DemoCredentials credentials) {
    _emailController.text = credentials.email;
    _passwordController.text = credentials.password;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: credentials.email,
            password: credentials.password,
          ),
        );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        );
  }

  String _localizeError(AppLocalizations l10n, String code) {
    return switch (code) {
      'validation' => l10n.loginEmailInvalid,
      'unauthorized' || 'user_not_found' || 'user_disabled' => l10n.loginInvalidCredentials,
      'network' || 'timeout' => l10n.errorNetwork,
      'forbidden' => l10n.errorForbidden,
      _ => l10n.errorGeneric,
    };
  }
}


class _DemoAccountButtons extends StatelessWidget {
  const _DemoAccountButtons({
    required this.enabled,
    required this.onSelect,
  });

  final bool enabled;
  final ValueChanged<DemoCredentials> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loginDemoAccountsTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _button(
              context,
              DemoAuthRemoteDataSource.patientCredentials,
              Icons.person_outline,
            ),
            _button(
              context,
              DemoAuthRemoteDataSource.doctorCredentials,
              Icons.medical_services_outlined,
            ),
            _button(
              context,
              DemoAuthRemoteDataSource.adminCredentials,
              Icons.admin_panel_settings_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _button(
    BuildContext context,
    DemoCredentials credentials,
    IconData icon,
  ) {
    return OutlinedButton.icon(
      onPressed: enabled ? () => onSelect(credentials) : null,
      icon: Icon(icon),
      label: Text(
        l10nLabel(context, credentials.label),
        textAlign: TextAlign.center,
      ),
    );
  }

  String l10nLabel(BuildContext context, String role) {
    final l10n = AppLocalizations.of(context);
    return switch (role) {
      'Patient' => l10n.loginDemoPatient,
      'Doctor' => l10n.loginDemoDoctor,
      _ => l10n.loginDemoAdmin,
    };
  }
}

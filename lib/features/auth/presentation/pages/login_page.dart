import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injector.dart';
import '../../data/datasources/demo_auth_remote_data_source.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: const _LoginView(),
    );
  }
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
                        if (getIt<AppConfig>().enableDemoAuth) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : _useDemoAccount,
                            icon: const Icon(Icons.play_circle_outline),
                            label: Text(l10n.loginDemoAccount),
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

  void _useDemoAccount() {
    _emailController.text = DemoAuthRemoteDataSource.email;
    _passwordController.text = DemoAuthRemoteDataSource.password;
    context.read<AuthBloc>().add(
          const AuthLoginRequested(
            email: DemoAuthRemoteDataSource.email,
            password: DemoAuthRemoteDataSource.password,
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
      'unauthorized' => l10n.loginInvalidCredentials,
      'network' || 'timeout' => l10n.errorNetwork,
      'forbidden' => l10n.errorForbidden,
      _ => l10n.errorGeneric,
    };
  }
}

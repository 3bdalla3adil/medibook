import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.registerSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.registerNameLabel,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) =>
                              value == null || value.trim().length < 2
                                  ? l10n.registerNameInvalid
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.loginEmailLabel,
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: (value) => value == null || !value.contains('@')
                              ? l10n.loginEmailInvalid
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          enabled: !isLoading,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.loginPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_outline),
                          ),
                          validator: (value) => value == null || value.length < 8
                              ? l10n.registerPasswordInvalid
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          enabled: !isLoading,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: l10n.registerConfirmPasswordLabel,
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                          ),
                          validator: (value) => value != _passwordController.text
                              ? l10n.registerPasswordsMismatch
                              : null,
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
                                : Text(l10n.actionCreateAccount),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(l10n.registerAlreadyHaveAccount),
                        ),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text,
          ),
        );
  }

  String _localizeError(AppLocalizations l10n, String code) {
    return switch (code) {
      'invalid_email' => l10n.loginEmailInvalid,
      'email_already_in_use' => l10n.registerEmailAlreadyInUse,
      'weak_password' => l10n.registerPasswordInvalid,
      'network' => l10n.errorNetwork,
      'operation_not_allowed' => l10n.registerUnavailable,
      _ => l10n.errorGeneric,
    };
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/admin_communique_remote_data_source.dart';

class AdminUserCreatePage extends StatefulWidget {
  const AdminUserCreatePage({
    required this.api,
    required this.token,
    super.key,
  });

  final AdminCommuniqueRemoteDataSource api;
  final String token;

  @override
  State<AdminUserCreatePage> createState() => _AdminUserCreatePageState();
}

class _AdminUserCreatePageState extends State<AdminUserCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _saving = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.api.createAdminUser(
        widget.token,
        fullName: _fullNameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final response = error is DioException ? error.response?.data : null;
      final message = response is Map ? response['error']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? context.l10n.adminCreateAdministratorFailure),
        ),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(context.l10n.adminNewAdministrator),
          actions: [
            IconButton(
              tooltip: context.l10n.adminCreateAccountTooltip,
              onPressed: _saving ? null : _create,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.person_add_alt_1_outlined),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  TextFormField(
                    controller: _fullNameController,
                    maxLength: 160,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.l10n.adminFullName,
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? context.l10n.adminFullNameRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameController,
                    maxLength: 64,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newUsername],
                    decoration: InputDecoration(
                      labelText: context.l10n.adminUsernameLabel,
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final username = value?.trim() ?? '';
                      if (username.length < 3) {
                        return context.l10n.adminUsernameMinLength;
                      }
                      if (username.contains(RegExp(r'\s'))) {
                        return context.l10n.adminUsernameNoSpaces;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: context.l10n.adminPasswordLabel,
                      helperText: context.l10n.adminPasswordMinHint,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                          ? context.l10n.adminShowPassword
                          : context.l10n.adminHidePassword,
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.length < 12
                        ? context.l10n.adminPasswordTooShort
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _saving ? null : _create(),
                    decoration: InputDecoration(
                      labelText: context.l10n.adminConfirmPassword,
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value != _passwordController.text
                        ? context.l10n.adminPasswordsMismatch
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _create,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(context.l10n.adminCreateAdministratorAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
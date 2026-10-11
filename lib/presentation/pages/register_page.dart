import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../providers/auth_provider.dart';
import '../widgets/sht_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    ref.read(authProvider.notifier).clearError();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.authAcceptTermsRequired),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ok = await ref.read(authProvider.notifier).register(
          displayName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          confirmPassword: _confirmController.text,
        );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final auth = ref.watch(authProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final onSurface = AppTheme.headerOnSurface;
    final onSurfaceMuted = AppTheme.headerOnSurfaceMuted;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: onSurface,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 4, 24, 24 + bottomInset),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: AppLogo(size: 84)),
                        const SizedBox(height: 16),
                        Text(
                          l10n.authCreateAccountTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.goldLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.authRegisterSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: onSurfaceMuted,
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: AppTheme.accentOnSurface,
                          autofillHints: const [AutofillHints.name],
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return l10n.authFullNameRequired;
                            if (v.length < 3) {
                              return l10n.authNameMinLength;
                            }
                            return null;
                          },
                          decoration: _fieldDecoration(
                            label: l10n.authFullName,
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: AppTheme.accentOnSurface,
                          autofillHints: const [AutofillHints.email],
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return l10n.authEmailRequired;
                            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v)) {
                              return l10n.authEmailInvalid;
                            }
                            return null;
                          },
                          decoration: _fieldDecoration(
                            label: l10n.authEmail,
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: AppTheme.accentOnSurface,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return null;
                            if (v.length < 8) return l10n.authPhoneInvalid;
                            return null;
                          },
                          decoration: _fieldDecoration(
                            label: l10n.authPhoneOptional,
                            icon: Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: AppTheme.accentOnSurface,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return l10n.authPasswordRequired;
                            if (v.length < 6) {
                              return l10n.authPasswordMinLength;
                            }
                            return null;
                          },
                          decoration: _fieldDecoration(
                            label: l10n.authPassword,
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          style: TextStyle(
                            color: onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: AppTheme.accentOnSurface,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) {
                              return l10n.authConfirmPasswordRequired;
                            }
                            if (v != _passwordController.text.trim()) {
                              return l10n.authPasswordMismatch;
                            }
                            return null;
                          },
                          decoration: _fieldDecoration(
                            label: l10n.authConfirmPassword,
                            icon: Icons.lock_person_outlined,
                            suffix: IconButton(
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                activeColor: AppTheme.accentOnSurface,
                                checkColor: AppTheme.ctaForeground,
                                side: BorderSide(
                                  color:
                                      AppTheme.accentOnSurface.withValues(alpha: 0.7),
                                ),
                                onChanged: auth.isLoading
                                    ? null
                                    : (value) => setState(
                                          () => _acceptTerms = value ?? false,
                                        ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.authAcceptTerms,
                                style: TextStyle(
                                  color: onSurfaceMuted,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.errorRed.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              authValidationMessage(l10n, auth.error!),
                              style: TextStyle(
                                color: onSurfaceMuted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.ctaBackground,
                              foregroundColor: AppTheme.ctaForeground,
                              disabledBackgroundColor:
                                  AppTheme.accentGold.withValues(alpha: 0.45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: auth.isLoading
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppTheme.ctaForeground,
                                    ),
                                  )
                                : Text(
                                    l10n.authCreateMyAccount,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: auth.isLoading
                              ? null
                              : () => Navigator.of(context).maybePop(),
                          child: Text.rich(
                            TextSpan(
                              text: l10n.authAlreadyHaveAccount,
                              style: TextStyle(color: onSurfaceMuted),
                              children: [
                                TextSpan(
                                  text: l10n.authLogin,
                                  style: TextStyle(
                                    color: AppTheme.accentOnSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.grey),
      floatingLabelStyle: TextStyle(
        color: AppTheme.accentOnSurface,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: AppTheme.accentOnSurface),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppTheme.surface.withValues(alpha: 0.92),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppTheme.accentOnSurface.withValues(alpha: 0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.accentOnSurface, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1.4),
      ),
      hintStyle: TextStyle(color: AppTheme.muted),
    );
  }
}

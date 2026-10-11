import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_communique_provider.dart';
import '../widgets/sht_widgets.dart';
import 'admin_communique_dashboard_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.adminMode = false});

  final bool adminMode;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _adminSubmitting = false;
  String? _adminError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showCreateAccountUnavailable() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          l10n.authCreateAccountUnavailableTitle,
          style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.authCreateAccountUnavailableMessage,
          style: TextStyle(
            color: AppTheme.softWhite,
            height: 1.45,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              l10n.ok,
              style: TextStyle(
                color: AppTheme.accentOnSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.adminMode) {
      setState(() {
        _adminSubmitting = true;
        _adminError = null;
      });
      try {
        final api = ref.read(adminCommuniqueDataSourceProvider);
        final session = await api.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        ref.read(adminSessionProvider.notifier).state = session;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const AdminCommuniqueDashboardPage(),
          ),
        );
      } catch (error) {
        if (!mounted) return;
        setState(() {
          _adminSubmitting = false;
          _adminError = _adminErrorMessage(error);
        });
      }
      return;
    }

    final l10n = context.l10n;
    final ok = await ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
          defaultDisplayName: l10n.authDefaultDisplayName,
        );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.authLoginSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _adminErrorMessage(Object error) {
    final response = error is DioException ? error.response?.data : null;
    if (response is Map && response['error'] != null) {
      return response['error'].toString();
    }
    return 'Connexion administrateur impossible. Vérifiez les identifiants et la connexion réseau.';
  }

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    final l10n = context.l10n;
    final auth = ref.watch(authProvider);
    final isLoading = widget.adminMode ? _adminSubmitting : auth.isLoading;
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxHeight < 640 ||
                  constraints.maxWidth < 380 ||
                  bottomInset > 0;
              final horizontalPadding = constraints.maxWidth < 480
                  ? 20.0
                  : 28.0;

              return Column(
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SizedBox(
                        width: double.infinity,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            color: onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        compact ? 0 : 8,
                        horizontalPadding,
                        24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(child: AppLogo(size: compact ? 72 : 88)),
                                SizedBox(height: compact ? 12 : 20),
                                Text(
                                  AppConstants.appName,
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
                                  widget.adminMode
                                      ? 'Administration'
                                      : l10n.authFaithfulSpace,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.goldLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.adminMode
                                      ? 'Connectez-vous pour gérer les communiqués.'
                                      : l10n.authLoginSubtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: onSurfaceMuted,
                                    fontSize: 13.5,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: compact ? 20 : 32),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: widget.adminMode
                                      ? TextInputType.text
                                      : TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                    color: onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  cursorColor: AppTheme.accentOnSurface,
                                  autofillHints: widget.adminMode
                                      ? const [AutofillHints.username]
                                      : const [AutofillHints.email],
                                  validator: (value) {
                                    final v = value?.trim() ?? '';
                                    if (v.isEmpty) {
                                      return widget.adminMode
                                          ? 'Saisissez votre nom d’utilisateur.'
                                          : l10n.authEmailRequired;
                                    }
                                    if (!widget.adminMode &&
                                        !RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                        ).hasMatch(v)) {
                                      return l10n.authEmailInvalid;
                                    }
                                    return null;
                                  },
                                  decoration: _fieldDecoration(
                                    label: widget.adminMode
                                        ? 'Nom d’utilisateur'
                                        : l10n.authEmail,
                                    icon: widget.adminMode
                                        ? Icons.person_outline
                                        : Icons.email_outlined,
                                  ),
                                ),
                                SizedBox(height: compact ? 10 : 14),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      isLoading ? null : _submit(),
                                  style: TextStyle(
                                    color: onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  cursorColor: AppTheme.accentOnSurface,
                                  autofillHints: const [AutofillHints.password],
                                  validator: (value) {
                                    final v = value?.trim() ?? '';
                                    if (v.isEmpty) {
                                      return l10n.authPasswordRequired;
                                    }
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
                                        () => _obscurePassword =
                                            !_obscurePassword,
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
                                if (!widget.adminMode)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: auth.isLoading
                                          ? null
                                          : () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    l10n.authForgotPasswordSoon,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            AppTheme.accentOnSurface,
                                      ),
                                      child: Text(l10n.authForgotPassword),
                                    ),
                                  ),
                                if ((widget.adminMode
                                        ? _adminError
                                        : auth.error) !=
                                    null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.errorRed.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.errorRed.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      widget.adminMode
                                          ? _adminError!
                                          : authValidationMessage(
                                              l10n,
                                              auth.error!,
                                            ),
                                      style: TextStyle(
                                        color: onSurfaceMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.ctaBackground,
                                      foregroundColor: AppTheme.ctaForeground,
                                      disabledBackgroundColor: AppTheme
                                          .accentGold
                                          .withValues(alpha: 0.45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                              color: AppTheme.ctaForeground,
                                            ),
                                          )
                                        : Text(
                                            widget.adminMode
                                                ? 'Accéder à l’administration'
                                                : l10n.authLogin,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                  ),
                                ),
                                if (!widget.adminMode)
                                  const SizedBox(height: 14),
                                if (!widget.adminMode)
                                  OutlinedButton(
                                    onPressed: isLoading
                                        ? null
                                        : _showCreateAccountUnavailable,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.accentOnSurface,
                                      side: BorderSide(
                                        color: AppTheme.accentOnSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.authCreateAccount,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                if (!widget.adminMode)
                                  const SizedBox(height: 28),
                                if (!widget.adminMode)
                                  Text(
                                    l10n.authContinueWithoutAccount,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppTheme.grey,
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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

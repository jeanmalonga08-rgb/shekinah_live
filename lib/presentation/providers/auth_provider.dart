import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';

class AuthUser {
  const AuthUser({
    required this.displayName,
    required this.email,
    this.phone,
  });

  final String displayName;
  final String email;
  final String? phone;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

enum AuthValidationError {
  credentialsRequired,
  emailInvalid,
  passwordMinLength,
  fullNameRequired,
  nameMinLength,
  phoneInvalid,
  passwordMismatch,
}

String authValidationMessage(AppLocalizations l10n, AuthValidationError error) {
  switch (error) {
    case AuthValidationError.credentialsRequired:
      return l10n.authCredentialsRequired;
    case AuthValidationError.emailInvalid:
      return l10n.authEmailInvalid;
    case AuthValidationError.passwordMinLength:
      return l10n.authPasswordMinLength;
    case AuthValidationError.fullNameRequired:
      return l10n.authFullNameRequired;
    case AuthValidationError.nameMinLength:
      return l10n.authNameMinLength;
    case AuthValidationError.phoneInvalid:
      return l10n.authPhoneInvalid;
    case AuthValidationError.passwordMismatch:
      return l10n.authPasswordMismatch;
  }
}

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  final AuthUser? user;
  final bool isLoading;
  final AuthValidationError? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AuthUser? user,
    bool? isLoading,
    AuthValidationError? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({
    required String email,
    required String password,
    required String defaultDisplayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      state = state.copyWith(
        error: AuthValidationError.credentialsRequired,
        clearError: false,
      );
      return false;
    }

    if (!_isValidEmail(trimmedEmail)) {
      state = state.copyWith(error: AuthValidationError.emailInvalid);
      return false;
    }

    if (trimmedPassword.length < 6) {
      state = state.copyWith(error: AuthValidationError.passwordMinLength);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Branchement cloud à venir (Supabase Auth / API Église).
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final name = trimmedEmail.split('@').first;
    final displayName = name
        .replaceAll(RegExp(r'[._-]'), ' ')
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
        .join(' ');

    state = AuthState(
      user: AuthUser(
        displayName:
            displayName.isEmpty ? defaultDisplayName : displayName,
        email: trimmedEmail,
      ),
    );
    return true;
  }

  Future<bool> register({
    required String displayName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedName = displayName.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();
    final trimmedPassword = password.trim();
    final trimmedConfirm = confirmPassword.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(error: AuthValidationError.fullNameRequired);
      return false;
    }
    if (trimmedName.length < 3) {
      state = state.copyWith(error: AuthValidationError.nameMinLength);
      return false;
    }
    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      state = state.copyWith(error: AuthValidationError.credentialsRequired);
      return false;
    }
    if (!_isValidEmail(trimmedEmail)) {
      state = state.copyWith(error: AuthValidationError.emailInvalid);
      return false;
    }
    if (trimmedPhone.isNotEmpty && trimmedPhone.length < 8) {
      state = state.copyWith(error: AuthValidationError.phoneInvalid);
      return false;
    }
    if (trimmedPassword.length < 6) {
      state = state.copyWith(error: AuthValidationError.passwordMinLength);
      return false;
    }
    if (trimmedPassword != trimmedConfirm) {
      state = state.copyWith(error: AuthValidationError.passwordMismatch);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    // Branchement cloud à venir (Supabase Auth / API Église).
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    state = AuthState(
      user: AuthUser(
        displayName: trimmedName,
        email: trimmedEmail,
        phone: trimmedPhone.isEmpty ? null : trimmedPhone,
      ),
    );
    return true;
  }

  void logout() {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}

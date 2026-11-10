import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/admin_communique_remote_data_source.dart';
import '../../domain/entities/admin_communique.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({
    required this.api,
    required this.session,
    required this.onChangePassword,
    required this.onCreateAdmin,
    required this.onLogout,
    super.key,
  });

  final AdminCommuniqueRemoteDataSource api;
  final AdminSession session;
  final VoidCallback onChangePassword;
  final Future<bool> Function() onCreateAdmin;
  final VoidCallback onLogout;

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  late Future<List<AdminAccount>> _adminsFuture;

  @override
  void initState() {
    super.initState();
    _adminsFuture = widget.api.fetchOtherAdmins(widget.session.accessToken);
  }

  void _reloadAdmins() {
    setState(() {
      _adminsFuture = widget.api.fetchOtherAdmins(widget.session.accessToken);
    });
  }

  Future<void> _createAdmin() async {
    if (await widget.onCreateAdmin() && mounted) _reloadAdmins();
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: Text(context.l10n.adminSettingsTitle)),
        body: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.surface,
                child: Icon(Icons.person_outline, color: AppTheme.accentOnSurface),
              ),
              title: Text(
                widget.session.fullName,
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(widget.session.role),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                context.l10n.adminAdministrators,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FutureBuilder<List<AdminAccount>>(
              future: _adminsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return ListTile(
                    leading: Icon(Icons.warning_amber_outlined, color: AppTheme.grey),
                    title: Text(
                      context.l10n.adminLoadAdminsFailure,
                      style: TextStyle(color: AppTheme.white),
                    ),
                    trailing: IconButton(
                      tooltip: context.l10n.adminRetry,
                      onPressed: _reloadAdmins,
                      icon: const Icon(Icons.refresh),
                    ),
                  );
                }

                final admins = snapshot.data ?? const <AdminAccount>[];
                if (admins.isEmpty) {
                  return ListTile(
                    leading: Icon(Icons.group_outlined, color: AppTheme.grey),
                    title: Text(
                      context.l10n.adminNoOtherAdmins,
                      style: TextStyle(color: AppTheme.grey),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final admin in admins)
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.surface,
                          child: Text(
                            _initials(admin.fullName),
                            style: TextStyle(color: AppTheme.accentOnSurface),
                          ),
                        ),
                        title: Text(
                          admin.fullName,
                          style: TextStyle(color: AppTheme.white),
                        ),
                        subtitle: Text('@${admin.username}'),
                        trailing: Text(
                          admin.role,
                          style: TextStyle(color: AppTheme.grey, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.key_outlined),
              title: Text(context.l10n.adminChangePasswordTitle),
              onTap: widget.onChangePassword,
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_outlined),
              title: Text(context.l10n.adminCreateAdministrator),
              onTap: _createAdmin,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: AppTheme.errorRed),
              title: Text(
                context.l10n.adminLogout,
                style: TextStyle(color: AppTheme.errorRed),
              ),
              onTap: widget.onLogout,
            ),
          ],
        ),
      );
}
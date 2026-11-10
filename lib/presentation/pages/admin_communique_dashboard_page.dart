import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/admin_communique_remote_data_source.dart';
import '../../data/services/admin_session_storage.dart';
import '../../domain/entities/admin_communique.dart';
import '../providers/admin_communique_provider.dart';
import 'admin_settings_page.dart';
import 'admin_user_create_page.dart';
import 'login_page.dart';
import '../widgets/communique_video_preview.dart';

class AdminCommuniqueDashboardPage extends ConsumerStatefulWidget {
  const AdminCommuniqueDashboardPage({super.key});

  @override
  ConsumerState<AdminCommuniqueDashboardPage> createState() =>
      _AdminCommuniqueDashboardPageState();
}

class _AdminCommuniqueDashboardPageState
    extends ConsumerState<AdminCommuniqueDashboardPage> {
  late Future<List<AdminCommunique>> _itemsFuture;
  int _filter = -1;
  bool _redirectingToLogin = false;

  AdminCommuniqueRemoteDataSource get _api =>
      ref.read(adminCommuniqueDataSourceProvider);

  @override
  void initState() {
    super.initState();
    final session = ref.read(adminSessionProvider);
    if (session != null && !session.isExpired) {
      _itemsFuture = _api.fetchAll(session.accessToken);
    } else {
      _itemsFuture = Future.value(const []);
    }
  }

  void _redirectToLogin() {
    if (_redirectingToLogin) return;
    _redirectingToLogin = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(adminSessionProvider.notifier).state = null;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const LoginPage(adminMode: true),
        ),
      );
    });
  }

  void _reload() {
    final session = ref.read(adminSessionProvider);
    if (session == null || session.isExpired) {
      ref.read(adminSessionProvider.notifier).state = null;
      return;
    }
    setState(() => _itemsFuture = _api.fetchAll(session.accessToken));
  }

  Future<void> _createDraft() async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminCommuniqueEditorPage(
          token: session.accessToken,
          api: _api,
        ),
      ),
    );
    if (changed == true && mounted) _reload();
  }

  Future<void> _editDraft(AdminCommunique item) async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminCommuniqueEditorPage(
          token: session.accessToken,
          api: _api,
          communique: item,
        ),
      ),
    );
    if (changed == true && mounted) _reload();
  }

  Future<void> _publish(AdminCommunique item) async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    final l10n = context.l10n;
    final confirmed = await _confirm(
      title: l10n.adminPublishConfirmTitle,
      message: l10n.adminPublishConfirmMessage,
      action: l10n.adminPublishAction,
    );
    if (!confirmed || !mounted) return;
    try {
      await _api.publish(session.accessToken, item.id);
      _showMessage(l10n.adminPublishSuccess);
      _reload();
    } catch (error) {
      _showMessage(_errorMessage(error, fallback: l10n.adminPublishFailure));
    }
  }

  Future<void> _archive(AdminCommunique item) async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    final l10n = context.l10n;
    final confirmed = await _confirm(
      title: l10n.adminArchiveConfirmTitle,
      message: l10n.adminArchiveConfirmMessage,
      action: l10n.adminArchiveAction,
    );
    if (!confirmed || !mounted) return;
    try {
      await _api.archive(session.accessToken, item.id);
      _showMessage(l10n.adminArchiveSuccess);
      _reload();
    } catch (error) {
      _showMessage(_errorMessage(error, fallback: l10n.adminArchiveFailure));
    }
  }

  Future<void> _delete(AdminCommunique item) async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    final l10n = context.l10n;
    final confirmed = await _confirm(
      title: l10n.adminDeleteConfirmTitle,
      message: l10n.adminDeleteConfirmMessage,
      action: l10n.adminDeleteAction,
    );
    if (!confirmed || !mounted) return;
    try {
      await _api.deleteCommunique(session.accessToken, item.id);
      _showMessage(l10n.adminDeleteSuccess);
      _reload();
    } catch (error) {
      _showMessage(_errorMessage(error, fallback: l10n.adminDeleteFailure));
    }
  }

  Future<bool> _createAdminUser() async {
    final session = ref.read(adminSessionProvider);
    if (session == null || session.isExpired) return false;
    final createdMessage = context.l10n.adminAdminCreated;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminUserCreatePage(api: _api, token: session.accessToken),
      ),
    );
    if (created == true && mounted) {
      _showMessage(createdMessage);
    }
    return created == true;
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.adminCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _logout() async {
    try {
      await AdminSessionStorage.clear();
    } catch (_) {
      if (mounted) _showMessage('Impossible de supprimer la session enregistrée.');
      return;
    }
    if (!mounted) return;
    ref.read(adminSessionProvider.notifier).state = null;
    _redirectToLogin();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorMessage(Object error, {required String fallback}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['error'] != null) return data['error'].toString();
      if (error.response?.statusCode == 401) {
        ref.read(adminSessionProvider.notifier).state = null;
        return context.l10n.adminSessionExpired;
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(adminSessionProvider);
    if (session == null || session.isExpired) {
      _redirectToLogin();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _buildDashboard(session);
  }

  Widget _buildDashboard(AdminSession session) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(context.l10n.adminCommuniques),
          actions: [
            IconButton(
              tooltip: context.l10n.adminRefresh,
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: context.l10n.adminAccountSettings,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AdminSettingsPage(
                    api: _api,
                    session: session,
                    onChangePassword: () => _changePassword(session),
                    onCreateAdmin: _createAdminUser,
                    onLogout: _logout,
                  ),
                ),
              ),
              icon: const Icon(Icons.manage_accounts_outlined),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createDraft,
          icon: const Icon(Icons.add),
          label: Text(context.l10n.adminCreateNew),
        ),
        body: FutureBuilder<List<AdminCommunique>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorPanel(
                message: _errorMessage(
                  snapshot.error!,
                  fallback: context.l10n.adminLoadCommuniquesFailed,
                ),
                onRetry: _reload,
              );
            }

            final all = snapshot.data ?? const <AdminCommunique>[];
            final visible = _filter < 0
                ? all
                : all.where((item) => item.status == _filter).toList();
            final drafts = all.where((item) => item.isDraft).length;
            final published = all.where((item) => item.isPublished).length;
            final archived = all.where((item) => item.isArchived).length;
            final recent = [...all]
              ..sort((a, b) {
                final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
                final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
                return bDate.compareTo(aDate);
              });
            final recentItems = recent.take(3).toList();
            final columns = MediaQuery.sizeOf(context).width >= 900 ? 4 : 2;

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.adminGreeting(session.fullName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            context.l10n.adminOverview,
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: columns == 4 ? 1.9 : 1.8,
                      ),
                      delegate: SliverChildListDelegate([
                        _DashboardMetricCard(
                          label: context.l10n.adminTotal,
                          count: all.length,
                          icon: Icons.campaign_outlined,
                          color: AppTheme.accentOnSurface,
                          selected: _filter == -1,
                          onTap: () => setState(() => _filter = -1),
                        ),
                        _DashboardMetricCard(
                          label: context.l10n.adminDrafts,
                          count: drafts,
                          icon: Icons.edit_note_rounded,
                          color: const Color(0xFFE3A52F),
                          selected: _filter == 0,
                          onTap: () => setState(() => _filter = 0),
                        ),
                        _DashboardMetricCard(
                          label: context.l10n.adminPublished,
                          count: published,
                          icon: Icons.check_circle_outline_rounded,
                          color: AppTheme.successGreen,
                          selected: _filter == 1,
                          onTap: () => setState(() => _filter = 1),
                        ),
                        _DashboardMetricCard(
                          label: context.l10n.adminArchived,
                          count: archived,
                          icon: Icons.archive_outlined,
                          color: AppTheme.grey,
                          selected: _filter == 2,
                          onTap: () => setState(() => _filter = 2),
                        ),
                      ]),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 28, 18, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.adminRecent,
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            context.l10n.adminRecentCount,
                            style: TextStyle(color: AppTheme.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (recentItems.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                        child: Text(
                          context.l10n.adminNoRecent,
                          style: TextStyle(color: AppTheme.grey),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      sliver: SliverList.builder(
                        itemCount: recentItems.length,
                        itemBuilder: (context, index) {
                          final item = recentItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _CommuniqueRow(
                              item: item,
                              onEdit: item.isDraft ? () => _editDraft(item) : null,
                              onPublish:
                                  item.isDraft ? () => _publish(item) : null,
                              onArchive: item.isArchived
                                  ? null
                                  : () => _archive(item),
                                onDelete: () => _delete(item),
                            ),
                          );
                        },
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 22, 18, 4),
                      child: Text(
                        context.l10n.adminAllCommuniques,
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                          _StatusFilter(
                            label: context.l10n.adminFilterAll,
                            count: all.length,
                            selected: _filter == -1,
                            onTap: () => setState(() => _filter = -1),
                          ),
                          _StatusFilter(
                            label: context.l10n.adminDrafts,
                            count: drafts,
                            selected: _filter == 0,
                            onTap: () => setState(() => _filter = 0),
                          ),
                          _StatusFilter(
                            label: context.l10n.adminPublished,
                            count: published,
                            selected: _filter == 1,
                            onTap: () => setState(() => _filter = 1),
                          ),
                          _StatusFilter(
                            label: context.l10n.adminArchived,
                            count: archived,
                            selected: _filter == 2,
                            onTap: () => setState(() => _filter = 2),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_outlined,
                                  size: 44, color: AppTheme.grey),
                              const SizedBox(height: 12),
                              Text(
                                all.isEmpty
                                    ? context.l10n.adminNoCommuniques
                                      : context.l10n.adminNoMatchingCommuniques,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      sliver: SliverList.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CommuniqueRow(
                              item: item,
                              onEdit: item.isDraft ? () => _editDraft(item) : null,
                              onPublish:
                                  item.isDraft ? () => _publish(item) : null,
                              onArchive: item.isArchived
                                  ? null
                                  : () => _archive(item),
                                onDelete: () => _delete(item),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );

  Future<void> _changePassword(AdminSession session) async {
    final l10n = context.l10n;
    final current = TextEditingController();
    final next = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.adminChangePasswordTitle),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: current,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminCurrentPassword,
                ),
                validator: (value) =>
                    value == null || value.isEmpty
                      ? l10n.adminRequired
                      : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: next,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.adminNewPassword,
                  helperText: l10n.adminPasswordMinHint,
                ),
                validator: (value) => value == null || value.length < 12
                    ? l10n.adminPasswordMinHint
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.adminCancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: Text(l10n.adminSave),
          ),
        ],
      ),
    );

    if (submit == true && mounted) {
      try {
        await _api.changePassword(
          session.accessToken,
          currentPassword: current.text,
          newPassword: next.text,
        );
        _showMessage(l10n.adminPasswordChanged);
        _logout();
      } catch (error) {
        _showMessage(
          _errorMessage(error, fallback: l10n.adminPasswordChangeFailure),
        );
      }
    }
    current.dispose();
    next.dispose();
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? color : AppTheme.borderSubtle,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppTheme.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: ChoiceChip(
          label: Text('$label  $count'),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );
}

class _CommuniqueRow extends StatelessWidget {
  const _CommuniqueRow({
    required this.item,
    required this.onEdit,
    required this.onPublish,
    required this.onArchive,
    required this.onDelete,
  });

  final AdminCommunique item;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final status = switch (item.status) {
      0 => (l10n.adminStatusDraft, colors.tertiary),
      1 => (l10n.adminStatusPublished, AppTheme.successGreen),
      _ => (l10n.adminStatusArchived, AppTheme.grey),
    };
    final when = item.publishedAt ?? item.updatedAt ?? item.createdAt;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.grey.withValues(alpha: 0.16)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusBadge(label: status.$1, color: status.$2),
                        Text(
                          _typeLabel(item.type, context),
                          style: TextStyle(color: AppTheme.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppTheme.grey, height: 1.35),
                    ),
                    if (when != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        DateFormat('dd/MM/yyyy · HH:mm').format(when.toLocal()),
                        style: TextStyle(color: AppTheme.muted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                IconButton(
                  tooltip: l10n.adminEditDraftTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (onPublish != null)
                IconButton(
                  tooltip: l10n.adminPublishTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onPublish,
                  color: AppTheme.successGreen,
                  icon: const Icon(Icons.send_rounded),
                ),
              if (onArchive != null)
                IconButton(
                  tooltip: l10n.adminArchiveTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                ),
              IconButton(
                tooltip: l10n.adminDeleteTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                color: AppTheme.errorRed,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

    String _typeLabel(int type, BuildContext context) => switch (type) {
      1 => context.l10n.adminTypeInformation,
      2 => context.l10n.adminTypeEvent,
      3 => context.l10n.adminTypeUrgent,
      4 => context.l10n.adminTypeWorship,
      _ => context.l10n.adminTypeOther,
      };
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              IconButton(
                onPressed: onRetry,
                tooltip: context.l10n.adminRetry,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
      );
}

class AdminCommuniqueEditorPage extends StatefulWidget {
  const AdminCommuniqueEditorPage({
    required this.token,
    required this.api,
    this.communique,
    super.key,
  });

  final String token;
  final AdminCommuniqueRemoteDataSource api;
  final AdminCommunique? communique;

  @override
  State<AdminCommuniqueEditorPage> createState() =>
      _AdminCommuniqueEditorPageState();
}

class _AdminCommuniqueEditorPageState
    extends State<AdminCommuniqueEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _imageController;
  XFile? _attachment;
  Uint8List? _attachmentPreviewBytes;
  String? _attachmentTextPreview;
  int? _attachmentSizeBytes;
  late int _type;
  DateTime? _expiresAt;
  bool _saving = false;

  bool get _editing => widget.communique != null;

  @override
  void initState() {
    super.initState();
    final item = widget.communique;
    _titleController = TextEditingController(text: item?.title ?? '');
    _bodyController = TextEditingController(text: item?.body ?? '');
    _imageController = TextEditingController(text: item?.imageUrl ?? '');
    _type = item?.type ?? 1;
    _expiresAt = item?.expiresAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _chooseExpiry() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      helpText: context.l10n.adminDatePickerHelp,
    );
    if (date == null) return;
    setState(() => _expiresAt = DateTime(date.year, date.month, date.day, 23, 59));
  }

  Future<void> _chooseAttachment() async {
    final l10n = context.l10n;
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: l10n.adminPickerImages,
            extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
          ),
          XTypeGroup(
            label: l10n.adminPickerDocuments,
            extensions: ['txt', 'pdf'],
          ),
          XTypeGroup(
            label: l10n.adminPickerVideos,
            extensions: ['mp4', 'mov', 'webm'],
          ),
        ],
      );
      if (file == null || !mounted) return;

      final extension = _fileExtension(file.name);
      final size = await file.length();
      final maximum = switch (extension) {
        'jpg' || 'jpeg' || 'png' || 'webp' || 'gif' => 15 * 1024 * 1024,
        'txt' || 'pdf' => 10 * 1024 * 1024,
        'mp4' || 'mov' || 'webm' => 100 * 1024 * 1024,
        _ => 0,
      };
      if (maximum == 0) {
        _showAttachmentError(l10n.adminUnsupportedFile);
        return;
      }
      if (size > maximum) {
        _showAttachmentError(
          l10n.adminFileTooLarge('${maximum ~/ (1024 * 1024)}'),
        );
        return;
      }

      Uint8List? previewBytes;
      String? textPreview;
      if (_isImage(extension) || extension == 'txt') {
        previewBytes = await file.readAsBytes();
        if (extension == 'txt') {
          try {
            textPreview = utf8.decode(previewBytes, allowMalformed: false);
          } on FormatException {
            _showAttachmentError(l10n.adminTextMustBeUtf8);
            return;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _attachment = file;
        _attachmentPreviewBytes = previewBytes;
        _attachmentTextPreview = textPreview;
        _attachmentSizeBytes = size;
      });
    } catch (_) {
      _showAttachmentError(l10n.adminFileOpenFailure);
    }
  }

  void _showAttachmentError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _fileExtension(String fileName) =>
      fileName.split('.').last.toLowerCase();

  bool _isImage(String extension) =>
      const {'jpg', 'jpeg', 'png', 'webp', 'gif'}.contains(extension);

  String _attachmentSize(BuildContext context, int bytes) => bytes < 1024 * 1024
      ? context.l10n.adminSizeKilobytes('${(bytes / 1024).ceil()}')
      : context.l10n.adminSizeMegabytes(
          (bytes / (1024 * 1024)).toStringAsFixed(1),
        );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final imageUrl = _attachment == null
          ? _imageController.text.trim()
          : await widget.api.uploadAttachment(widget.token, _attachment!);
      final args = {
        'title': _titleController.text,
        'body': _bodyController.text,
        'type': _type,
        'imageUrl': imageUrl,
        'expiresAt': _expiresAt,
      };
      if (_editing) {
        await widget.api.updateDraft(
          widget.token,
          widget.communique!.id,
          title: args['title']! as String,
          body: args['body']! as String,
          type: args['type']! as int,
          imageUrl: args['imageUrl']! as String,
          expiresAt: args['expiresAt'] as DateTime?,
        );
      } else {
        await widget.api.createDraft(
          widget.token,
          title: args['title']! as String,
          body: args['body']! as String,
          type: args['type']! as int,
          imageUrl: args['imageUrl']! as String,
          expiresAt: args['expiresAt'] as DateTime?,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      final message = error is DioException && error.response?.data is Map
          ? (error.response!.data as Map)['error']?.toString()
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? l10n.adminSaveFailure)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            _editing ? context.l10n.adminEditDraft : context.l10n.adminNewCommunique,
          ),
          actions: [
            IconButton(
              tooltip: context.l10n.adminSaveDraft,
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              TextFormField(
                controller: _titleController,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.adminTitle,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.adminTitleRequired
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: context.l10n.adminCommuniqueType,
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 1,
                    child: Text(context.l10n.adminTypeInformation),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text(context.l10n.adminTypeEvent),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text(context.l10n.adminTypeUrgent),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text(context.l10n.adminTypeWorship),
                  ),
                  DropdownMenuItem(
                    value: 99,
                    child: Text(context.l10n.adminTypeOther),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _type = value);
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                minLines: 8,
                maxLines: 16,
                maxLength: 50000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.adminBody,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l10n.adminBodyRequired
                    : null,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _saving ? null : _chooseAttachment,
                icon: const Icon(Icons.attach_file_rounded),
                label: Text(
                  _attachment == null
                      ? context.l10n.adminChooseAttachment
                      : context.l10n.adminReplaceAttachment,
                ),
              ),
              if (_attachment != null) ...[
                const SizedBox(height: 10),
                _AttachmentPreview(
                  file: _attachment!,
                  previewBytes: _attachmentPreviewBytes,
                  textPreview: _attachmentTextPreview,
                  isImage: _isImage(_fileExtension(_attachment!.name)),
                  isText: _fileExtension(_attachment!.name) == 'txt',
                  isVideo: const {'mp4', 'mov', 'webm'}
                      .contains(_fileExtension(_attachment!.name)),
                    formattedSize:
                      _attachmentSize(context, _attachmentSizeBytes ?? 0),
                  onRemove: _saving
                      ? null
                      : () => setState(() {
                            _attachment = null;
                            _attachmentPreviewBytes = null;
                            _attachmentTextPreview = null;
                            _attachmentSizeBytes = null;
                          }),
                ),
              ],
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy_outlined),
                title: Text(
                  _expiresAt == null
                      ? context.l10n.adminExpiryNone
                      : context.l10n.adminExpiresOn(
                          DateFormat('dd/MM/yyyy').format(_expiresAt!),
                        ),
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: context.l10n.adminChooseExpiry,
                      onPressed: _saving ? null : _chooseExpiry,
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                    if (_expiresAt != null)
                      IconButton(
                        tooltip: context.l10n.adminClearExpiry,
                        onPressed: _saving
                            ? null
                            : () => setState(() => _expiresAt = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  _saving
                      ? context.l10n.adminSaving
                      : context.l10n.adminSaveDraft,
                ),
              ),
            ],
          ),
        ),
      );
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    required this.file,
    required this.previewBytes,
    required this.textPreview,
    required this.isImage,
    required this.isText,
    required this.isVideo,
    required this.formattedSize,
    required this.onRemove,
  });

  final XFile file;
  final Uint8List? previewBytes;
  final String? textPreview;
  final bool isImage;
  final bool isText;
  final bool isVideo;
  final String formattedSize;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final icon = isImage
        ? Icons.image_outlined
        : isVideo
            ? Icons.video_file_outlined
            : isText
                ? Icons.description_outlined
                : Icons.picture_as_pdf_outlined;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentOnSurface),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      formattedSize,
                      style: TextStyle(color: AppTheme.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.l10n.adminRemoveAttachment,
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (isImage && previewBytes != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                previewBytes!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(
                  height: 100,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          ] else if (isText) ...[
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  textPreview ?? '',
                  style: TextStyle(
                    color: AppTheme.softWhite,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ] else if (isVideo) ...[
            const SizedBox(height: 10),
            CommuniqueVideoPreview(source: file.path, isLocal: true),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.adminDocumentAfterPublish,
              style: TextStyle(color: AppTheme.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
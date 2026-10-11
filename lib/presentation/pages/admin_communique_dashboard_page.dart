import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/datasources/admin_communique_remote_data_source.dart';
import '../../domain/entities/admin_communique.dart';
import '../providers/admin_communique_provider.dart';
import 'admin_user_create_page.dart';
import 'login_page.dart';

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
    final confirmed = await _confirm(
      title: 'Publier ce communiqué ?',
      message: 'Une notification sera envoyée aux appareils enregistrés.',
      action: 'Publier',
    );
    if (!confirmed || !mounted) return;
    try {
      await _api.publish(session.accessToken, item.id);
      _showMessage('Communiqué publié.');
      _reload();
    } catch (error) {
      _showMessage(_errorMessage(error, fallback: 'Publication impossible.'));
    }
  }

  Future<void> _archive(AdminCommunique item) async {
    final session = ref.read(adminSessionProvider);
    if (session == null) return;
    final confirmed = await _confirm(
      title: 'Archiver ce communiqué ?',
      message: 'Il ne sera plus visible dans la liste publique.',
      action: 'Archiver',
    );
    if (!confirmed || !mounted) return;
    try {
      await _api.archive(session.accessToken, item.id);
      _showMessage('Communiqué archivé.');
      _reload();
    } catch (error) {
      _showMessage(_errorMessage(error, fallback: 'Archivage impossible.'));
    }
  }

  Future<void> _createAdminUser() async {
    final session = ref.read(adminSessionProvider);
    if (session == null || session.isExpired) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminUserCreatePage(api: _api, token: session.accessToken),
      ),
    );
    if (created == true && mounted) {
      _showMessage('Compte administrateur créé.');
    }
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
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  void _logout() {
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
        return 'Session expirée. Connectez-vous à nouveau.';
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
          title: const Text('Communiqués'),
          actions: [
            IconButton(
              tooltip: 'Actualiser',
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
            ),
            PopupMenuButton<String>(
              tooltip: 'Compte administrateur',
              onSelected: (value) {
                if (value == 'password') _changePassword(session);
                if (value == 'create-admin') _createAdminUser();
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'password',
                  child: ListTile(
                    leading: Icon(Icons.key_outlined),
                    title: Text('Changer le mot de passe'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'create-admin',
                  child: ListTile(
                    leading: Icon(Icons.person_add_alt_1_outlined),
                    title: Text('Créer un administrateur'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Déconnexion'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _createDraft,
          icon: const Icon(Icons.add),
          label: const Text('Nouveau'),
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
                  fallback: 'Impossible de charger les communiqués.',
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

            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.fullName,
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${all.length} total',
                            style: TextStyle(color: AppTheme.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 76,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _StatusFilter(
                            label: 'Tous',
                            count: all.length,
                            selected: _filter == -1,
                            onTap: () => setState(() => _filter = -1),
                          ),
                          _StatusFilter(
                            label: 'Brouillons',
                            count: drafts,
                            selected: _filter == 0,
                            onTap: () => setState(() => _filter = 0),
                          ),
                          _StatusFilter(
                            label: 'Publiés',
                            count: published,
                            selected: _filter == 1,
                            onTap: () => setState(() => _filter = 1),
                          ),
                          _StatusFilter(
                            label: 'Archivés',
                            count: archived,
                            selected: _filter == 2,
                            onTap: () => setState(() => _filter = 2),
                          ),
                        ],
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
                                    ? 'Aucun communiqué. Créez un premier brouillon.'
                                    : 'Aucun communiqué dans cette catégorie.',
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
    final current = TextEditingController();
    final next = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final submit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: current,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: next,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  helperText: '12 caractères minimum',
                ),
                validator: (value) => value == null || value.length < 12
                    ? '12 caractères minimum'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Enregistrer'),
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
        _showMessage('Mot de passe modifié. Reconnectez-vous.');
        _logout();
      } catch (error) {
        _showMessage(_errorMessage(error, fallback: 'Modification impossible.'));
      }
    }
    current.dispose();
    next.dispose();
  }
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
  });

  final AdminCommunique item;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = switch (item.status) {
      0 => ('Brouillon', colors.tertiary),
      1 => ('Publié', AppTheme.successGreen),
      _ => ('Archivé', AppTheme.grey),
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
                          _typeLabel(item.type),
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
          PopupMenuButton<String>(
            tooltip: 'Actions du communiqué',
            onSelected: (value) {
              if (value == 'edit') onEdit?.call();
              if (value == 'publish') onPublish?.call();
              if (value == 'archive') onArchive?.call();
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Modifier'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (onPublish != null)
                const PopupMenuItem(
                  value: 'publish',
                  child: ListTile(
                    leading: Icon(Icons.send_outlined),
                    title: Text('Publier'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (onArchive != null)
                const PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    leading: Icon(Icons.archive_outlined),
                    title: Text('Archiver'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _typeLabel(int type) => switch (type) {
        1 => 'Information',
        2 => 'Événement',
        3 => 'Urgent',
        4 => 'Culte',
        _ => 'Autre',
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
                tooltip: 'Réessayer',
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
      helpText: 'Date d’expiration',
    );
    if (date == null) return;
    setState(() => _expiresAt = DateTime(date.year, date.month, date.day, 23, 59));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final args = {
        'title': _titleController.text,
        'body': _bodyController.text,
        'type': _type,
        'imageUrl': _imageController.text,
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
        SnackBar(content: Text(message ?? 'Enregistrement impossible.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(_editing ? 'Modifier le brouillon' : 'Nouveau communiqué'),
          actions: [
            IconButton(
              tooltip: 'Enregistrer le brouillon',
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
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Le titre est obligatoire.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Type de communiqué',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Information')),
                  DropdownMenuItem(value: 2, child: Text('Événement')),
                  DropdownMenuItem(value: 3, child: Text('Urgent')),
                  DropdownMenuItem(value: 4, child: Text('Culte')),
                  DropdownMenuItem(value: 99, child: Text('Autre')),
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
                decoration: const InputDecoration(
                  labelText: 'Texte du communiqué',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Le texte est obligatoire.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de l’image (facultatif)',
                  prefixIcon: Icon(Icons.image_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final uri = Uri.tryParse(value.trim());
                  return uri != null &&
                          (uri.scheme == 'https' || uri.scheme == 'http') &&
                          uri.host.isNotEmpty
                      ? null
                      : 'Saisissez une URL HTTP ou HTTPS valide.';
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_busy_outlined),
                title: Text(
                  _expiresAt == null
                      ? 'Aucune date d’expiration'
                      : 'Expire le ${DateFormat('dd/MM/yyyy').format(_expiresAt!)}',
                ),
                trailing: Wrap(
                  children: [
                    IconButton(
                      tooltip: 'Choisir une date',
                      onPressed: _saving ? null : _chooseExpiry,
                      icon: const Icon(Icons.calendar_month_outlined),
                    ),
                    if (_expiresAt != null)
                      IconButton(
                        tooltip: 'Effacer la date',
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
                label: Text(_saving ? 'Enregistrement…' : 'Enregistrer le brouillon'),
              ),
            ],
          ),
        ),
      );
}
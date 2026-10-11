import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/network/notifications_api_config.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/notification_item.dart';
import '../navigation/notification_navigation.dart';
import '../providers/app_update_provider.dart';
import '../providers/cantique_provider.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    if (notificationsApiEnabled) {
      Future.microtask(
        () => ref.read(notificationsListProvider.notifier).refresh(),
      );
    }
  }

  String _timeLabel(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return l10n.today;
    if (diff.inHours < 24 && now.day == date.day) return l10n.today;
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.thisWeek;
    return DateFormat.yMMMd(Localizations.localeOf(context).toString())
        .format(date);
  }

  Future<void> _openItem(NotificationItem item) async {
    await ref.read(notificationsListProvider.notifier).markRead(item.id);
    if (!mounted) return;
    await openNotificationRoute(
      route: item.route,
      refType: item.refType,
      refId: item.refId,
      cantiques: ref.read(cantiqueListProvider).valueOrNull,
      resolveAppUpdateStoreUrl: () async {
        try {
          final remote =
              await ref.read(appUpdateRemoteDataSourceProvider).fetchUpdateInfo();
          if (remote == null) return defaultAppUpdateStoreUrl();
          if (!kIsWeb && Platform.isIOS) {
            final ios = remote.iosStoreUrl;
            if (ios != null && ios.isNotEmpty) return ios;
            return null;
          }
          if (remote.androidStoreUrl.isNotEmpty) return remote.androidStoreUrl;
        } catch (_) {}
        return defaultAppUpdateStoreUrl();
      },
    );
    if ((item.refType ?? '').toLowerCase() == 'app_update' ||
        item.type.toLowerCase().contains('appupdate')) {
      ref.invalidate(appUpdatePromptProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncItems = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          asyncItems.maybeWhen(
            data: (items) {
              final unread = items.where((n) => n.unread).length;
              if (unread == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () =>
                    ref.read(notificationsListProvider.notifier).markAllRead(),
                child: Text(l10n.notificationsMarkAllRead),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsListProvider.notifier).refresh(),
        child: asyncItems.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.grey),
              const SizedBox(height: 12),
              Text(
                'Impossible de charger les notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.softWhite),
              ),
            ],
          ),
          data: (items) {
            final unread = items.where((n) => n.unread).length;
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Icon(Icons.notifications_none_outlined,
                      size: 48, color: AppTheme.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune notification pour le moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.softWhite),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accentOnSurface.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: unread > 0
                              ? AppTheme.crossRed
                              : AppTheme.surfaceElevated,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.notificationUnread(unread),
                          style: TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NotificationTile(
                      item: item,
                      timeLabel: _timeLabel(context, item.publishedAt),
                      onTap: () => _openItem(item),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  final NotificationItem item;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final icon = notificationIconForType(item.type);

    return Material(
      color: item.unread ? AppTheme.surfaceElevated : AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.unread
                  ? AppTheme.accentOnSurface.withValues(alpha: 0.35)
                  : AppTheme.accentOnSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlue.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppTheme.accentOnSurface, size: 22),
                  ),
                  if (item.unread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.crossRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.surfaceElevated,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: AppTheme.white,
                              fontWeight: item.unread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: TextStyle(color: AppTheme.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      style: TextStyle(
                        color: AppTheme.softWhite,
                        height: 1.45,
                        fontSize: 13,
                      ),
                    ),
                    if (item.unread) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.notificationsUnread,
                        style: TextStyle(
                          color: AppTheme.goldOnSurface,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

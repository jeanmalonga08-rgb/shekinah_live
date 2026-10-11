import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/notifications_api_config.dart';
import '../../data/services/installation_id_service.dart';
import '../../domain/entities/notification_item.dart';
import 'notifications_api_provider.dart';

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListNotifier, List<NotificationItem>>(
  NotificationsListNotifier.new,
);

final notificationsUnreadCountProvider = FutureProvider<int>((ref) async {
  if (!notificationsApiEnabled) return 0;
  try {
    final installationId = await InstallationIdService.getOrCreate();
    return await ref
        .read(notificationsDataSourceProvider)
        .fetchUnreadCount(installationId);
  } catch (_) {
    final list = ref.watch(notificationsListProvider).valueOrNull;
    if (list == null) return 0;
    return list.where((n) => n.unread).length;
  }
});

class NotificationsListNotifier extends AsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> markRead(String notificationId) async {
    if (!notificationsApiEnabled) return;
    final installationId = await InstallationIdService.getOrCreate();
    await ref.read(notificationsDataSourceProvider).markRead(
          installationId: installationId,
          notificationId: notificationId,
        );
    state = state.whenData(
      (items) => items
          .map(
            (n) => n.id == notificationId
                ? NotificationItem(
                    id: n.id,
                    type: n.type,
                    title: n.title,
                    body: n.body,
                    imageUrl: n.imageUrl,
                    topic: n.topic,
                    refType: n.refType,
                    refId: n.refId,
                    route: n.route,
                    publishedAt: n.publishedAt,
                    unread: false,
                  )
                : n,
          )
          .toList(),
    );
    ref.invalidate(notificationsUnreadCountProvider);
  }

  Future<void> markAllRead() async {
    if (!notificationsApiEnabled) return;
    final installationId = await InstallationIdService.getOrCreate();
    await ref.read(notificationsDataSourceProvider).markAllRead(installationId);
    state = state.whenData(
      (items) => items
          .map(
            (n) => NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              imageUrl: n.imageUrl,
              topic: n.topic,
              refType: n.refType,
              refId: n.refId,
              route: n.route,
              publishedAt: n.publishedAt,
              unread: false,
            ),
          )
          .toList(),
    );
    ref.invalidate(notificationsUnreadCountProvider);
  }

  Future<List<NotificationItem>> _load() async {
    if (!notificationsApiEnabled) return const [];
    final installationId = await InstallationIdService.getOrCreate();
    return ref.read(notificationsDataSourceProvider).fetchNotifications(
          installationId: installationId,
        );
  }
}

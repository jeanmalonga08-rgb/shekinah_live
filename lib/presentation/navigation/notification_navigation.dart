import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/navigation/app_navigator.dart';
import '../../domain/entities/cantique.dart';
import '../pages/a_la_lune_page.dart';
import '../pages/archives_page.dart';
import '../pages/cantique_detail_page.dart';
import '../pages/cantiques_page.dart';
import '../pages/communique_detail_page.dart';
import '../pages/live_page.dart';
import '../pages/library_page.dart';
import '../pages/offline_page.dart';

class _NotificationRouteIntent {
  const _NotificationRouteIntent({
    required this.route,
    this.refType,
    this.refId,
    this.cantiques,
    this.resolveAppUpdateStoreUrl,
  });

  final String route;
  final String? refType;
  final String? refId;
  final List<Cantique>? cantiques;
  final Future<String?> Function()? resolveAppUpdateStoreUrl;
}

_NotificationRouteIntent? _pendingNotificationRoute;
bool _mainShellReady = false;

/// À appeler quand [MainNavigation] est monté (après le splash).
void markAppMainShellReady() {
  _mainShellReady = true;
}

/// Ouvre une route en attente une fois l’accueil prêt (ex. tap notif au cold start).
Future<void> flushPendingNotificationRoute() async {
  final pending = _pendingNotificationRoute;
  if (pending == null) return;
  if (!_mainShellReady || appNavigatorKey.currentState == null) return;

  _pendingNotificationRoute = null;
  await _openNotificationRouteNow(
    route: pending.route,
    refType: pending.refType,
    refId: pending.refId,
    cantiques: pending.cantiques,
    resolveAppUpdateStoreUrl: pending.resolveAppUpdateStoreUrl,
  );
}

Future<void> openNotificationRoute({
  required String route,
  String? refType,
  String? refId,
  List<Cantique>? cantiques,
  Future<String?> Function()? resolveAppUpdateStoreUrl,
}) async {
  if (!_mainShellReady || appNavigatorKey.currentState == null) {
    _pendingNotificationRoute = _NotificationRouteIntent(
      route: route,
      refType: refType,
      refId: refId,
      cantiques: cantiques,
      resolveAppUpdateStoreUrl: resolveAppUpdateStoreUrl,
    );
    return;
  }

  await _openNotificationRouteNow(
    route: route,
    refType: refType,
    refId: refId,
    cantiques: cantiques,
    resolveAppUpdateStoreUrl: resolveAppUpdateStoreUrl,
  );
}

Future<void> _openNotificationRouteNow({
  required String route,
  String? refType,
  String? refId,
  List<Cantique>? cantiques,
  Future<String?> Function()? resolveAppUpdateStoreUrl,
}) async {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) {
    _pendingNotificationRoute = _NotificationRouteIntent(
      route: route,
      refType: refType,
      refId: refId,
      cantiques: cantiques,
      resolveAppUpdateStoreUrl: resolveAppUpdateStoreUrl,
    );
    return;
  }

  final normalized = route.startsWith('/') ? route : '/$route';
  final ref = (refType ?? '').toLowerCase();

  if (ref == 'app_update' ||
      normalized == '/app-update' ||
      normalized == '/app_update') {
    final url = resolveAppUpdateStoreUrl != null
        ? await resolveAppUpdateStoreUrl()
        : defaultAppUpdateStoreUrl();
    if (url != null && url.isNotEmpty) {
      await launchExternalUrl(url);
    }
    return;
  }

  if (normalized == '/live' || ref == 'live') {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const LivePage()),
    );
    return;
  }

  if (normalized == '/offline') {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const OfflinePage()),
    );
    return;
  }

  if (normalized == '/library') {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const LibraryPage()),
    );
    return;
  }

  if (normalized == '/a-la-lune') {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const ALaLunePage()),
    );
    return;
  }

  if (normalized.startsWith('/communiques/')) {
    final id = refId ?? normalized.split('/').last;
    if (id.isNotEmpty) {
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => CommuniqueDetailPage(communiqueId: id),
        ),
      );
    }
    return;
  }

  if (normalized.startsWith('/cantiques')) {
    final id = refId ?? normalized.split('/').last;
    Cantique? match;
    if (cantiques != null) {
      for (final c in cantiques) {
        if (c.id == id) {
          match = c;
          break;
        }
      }
    }
    if (match != null) {
      await navigator.push(
        MaterialPageRoute(builder: (_) => CantiqueDetailPage(cantique: match!)),
      );
    } else {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const CantiquesPage()),
      );
    }
    return;
  }

  if (normalized.startsWith('/predications')) {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const ArchivesPage()),
    );
    return;
  }

  if (ref == 'audio_conversion') {
    await navigator.push(
      MaterialPageRoute(builder: (_) => const OfflinePage()),
    );
  }
}

String? defaultAppUpdateStoreUrl() {
  if (kIsWeb) return AppConstants.playStoreUrl;
  if (!kIsWeb && Platform.isIOS) return null;
  return AppConstants.playStoreUrl;
}

Future<void> launchExternalUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

IconData notificationIconForType(String type) {
  final lower = type.toLowerCase();
  if (lower.contains('appupdate') || lower.contains('app_update')) {
    return Icons.system_update_alt_rounded;
  }
  if (lower.contains('livestarted') || lower.contains('live')) {
    return Icons.live_tv_outlined;
  }
  if (lower.contains('audioconversion') || lower.contains('audio_conversion')) {
    return Icons.audiotrack_rounded;
  }
  if (lower.contains('predication')) {
    return Icons.mic_outlined;
  }
  if (lower.contains('cantique')) {
    return Icons.music_note_outlined;
  }
  if (lower.contains('communique')) {
    return Icons.campaign_outlined;
  }
  return Icons.notifications_outlined;
}

/// Route cible pour une notification push (data FCM).
String? resolvePushNotificationRoute(Map<String, dynamic> data) {
  var route = data['route']?.toString().trim();
  if (route != null && route.isNotEmpty && route != '/') return route;

  final refType = data['ref_type']?.toString().toLowerCase() ?? '';
  final type = data['type']?.toString().toLowerCase() ?? '';
  final refId = data['ref_id']?.toString().trim() ?? '';

  if (refType == 'live' ||
      type == 'live' ||
      type.contains('live')) {
    return '/live';
  }
  if (refType == 'app_update' || type.contains('appupdate')) {
    return '/app-update';
  }
  if (refType == 'audio_conversion' || type.contains('audioconversion')) {
    return '/offline';
  }
  if (refType == 'library' || type.contains('library')) {
    return '/library';
  }
  if (refType == 'predication' || type.contains('predication')) {
    return refId.isEmpty ? '/predications' : '/predications/$refId';
  }
  if (refType == 'cantique' || type.contains('cantique')) {
    return refId.isEmpty ? '/cantiques' : '/cantiques/$refId';
  }
  if (refType == 'communique' || type.contains('communique')) {
    return '/a-la-lune';
  }
  return null;
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../providers/notifications_api_provider.dart';
import '../widgets/content_share_helper.dart';
import '../widgets/communique_video_preview.dart';

class CommuniqueDetailPage extends ConsumerStatefulWidget {
  const CommuniqueDetailPage({required this.communiqueId, super.key});

  final String communiqueId;

  @override
  ConsumerState<CommuniqueDetailPage> createState() =>
      _CommuniqueDetailPageState();
}

class _CommuniqueDetailPageState extends ConsumerState<CommuniqueDetailPage> {
  late Future<Map<String, dynamic>> _communiqueFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _communiqueFuture = ref
        .read(notificationsApiDioProvider)
        .get<Map<String, dynamic>>('/api/v1/communiques/${widget.communiqueId}')
        .then((response) => response.data ?? <String, dynamic>{});
  }

  Future<void> _shareCommunique() async {
    try {
      final item = await _communiqueFuture;
      if (!mounted) return;

      final title = item['title']?.toString().trim() ?? '';
      final body = item['body']?.toString().trim() ?? '';
      if (title.isEmpty) return;

      final l10n = context.l10n;
      final invitation = l10n.shareAppMessage(
        AppConstants.appName,
        AppConstants.appStoreUrl,
        AppConstants.playStoreUrl,
        AppConstants.websiteUrl,
      );
      await shareTextContent(
        context,
        text: 'Communiqué : $title\n\n$body\n\n$invitation',
        subject: title,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de partager ce communiqué.')),
      );
    }
  }

  String _typeLabel(Object? rawType) => switch (rawType) {
    1 || '1' => 'Information',
    2 || '2' => 'Événement',
    3 || '3' => 'Urgent',
    4 || '4' => 'Culte',
    _ => 'Communiqué',
  };

  Color _typeColor(Object? rawType) =>
      switch (int.tryParse(rawType.toString())) {
        1 => AppTheme.royalBlue,
        2 => const Color(0xFF138A78),
        3 => AppTheme.errorRed,
        4 => const Color(0xFF7652A8),
        _ => AppTheme.accentGold,
      };

  IconData _typeIcon(Object? rawType) =>
      switch (int.tryParse(rawType.toString())) {
        1 => Icons.info_outline_rounded,
        2 => Icons.event_outlined,
        3 => Icons.priority_high_rounded,
        4 => Icons.church_outlined,
        _ => Icons.campaign_outlined,
      };

  String _extensionOf(Uri uri) => uri.pathSegments.isEmpty
      ? ''
      : uri.pathSegments.last.split('.').last.toLowerCase();

  Widget _attachment(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return const SizedBox.shrink();
    final extension = _extensionOf(uri);
    if (const {'jpg', 'jpeg', 'png', 'webp', 'gif'}.contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, _, _) => const SizedBox.shrink(),
        ),
      );
    }
    if (const {'mp4', 'mov', 'webm'}.contains(extension)) {
      return CommuniqueVideoPreview(source: url);
    }

    final name = uri.pathSegments.isEmpty
        ? 'Document joint'
        : uri.pathSegments.last;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            extension == 'txt'
                ? Icons.description_outlined
                : Icons.picture_as_pdf_outlined,
            color: typeColorForAttachment,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Ouvrir le document',
            onPressed: () =>
                launchUrl(uri, mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
    );
  }

  Color get typeColorForAttachment => AppTheme.accentOnSurface;

  Widget _typeAvatar(Object? rawType, Color color) => Container(
    height: 150,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.24)),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 22,
          top: 14,
          child: Icon(
            _typeIcon(rawType),
            size: 120,
            color: color.withValues(alpha: 0.09),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon(rawType), size: 30, color: color),
            ),
            const SizedBox(height: 9),
            Text(
              _typeLabel(rawType),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Communiqué'),
        actions: [
          IconButton(
            tooltip: 'Partager',
            onPressed: _shareCommunique,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _communiqueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 42,
                      color: AppTheme.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ce communiqué n’est pas disponible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.softWhite),
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      tooltip: 'Réessayer',
                      onPressed: () => setState(_load),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            );
          }

          final item = snapshot.data!;
          final title = item['title']?.toString() ?? '';
          final body = item['body']?.toString() ?? '';
          final imageUrl = item['imageUrl']?.toString();
          final author = item['author']?.toString().trim();
          final typeColor = _typeColor(item['type']);
          final publishedAt = DateTime.tryParse(
            item['publishedAt']?.toString() ?? '',
          )?.toLocal();

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon(item['type']), size: 18, color: typeColor),
                    const SizedBox(width: 8),
                    Text(
                      _typeLabel(item['type']).toUpperCase(),
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.16,
                ),
              ),
              if (publishedAt != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: AppTheme.grey,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      DateFormat.yMMMMd('fr_FR').add_Hm().format(publishedAt),
                      style: TextStyle(color: AppTheme.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 22),
                _attachment(imageUrl),
              ] else ...[
                const SizedBox(height: 22),
                _typeAvatar(item['type'], typeColor),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      body,
                      style: TextStyle(
                        color: AppTheme.softWhite,
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Divider(color: AppTheme.divider, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: typeColor.withValues(alpha: 0.14),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 19,
                            color: typeColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Publié par',
                                style: TextStyle(
                                  color: AppTheme.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                author == null || author.isEmpty
                                    ? 'Administration Shekinah'
                                    : author,
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

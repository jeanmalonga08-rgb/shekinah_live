import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../providers/notifications_api_provider.dart';

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
        .get<Map<String, dynamic>>(
          '/api/v1/communiques/${widget.communiqueId}',
        )
        .then((response) => response.data ?? <String, dynamic>{});
  }

  String _typeLabel(Object? rawType) => switch (rawType) {
        1 || '1' => 'Information',
        2 || '2' => 'Événement',
        3 || '3' => 'Urgent',
        4 || '4' => 'Culte',
        _ => 'Communiqué',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Communiqué')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _communiqueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined,
                        size: 42, color: AppTheme.grey),
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
          final publishedAt = DateTime.tryParse(
            item['publishedAt']?.toString() ?? '',
          )?.toLocal();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                _typeLabel(item['type']),
                style: TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              if (publishedAt != null) ...[
                const SizedBox(height: 10),
                Text(
                  DateFormat.yMMMMd('fr_FR').add_Hm().format(publishedAt),
                  style: TextStyle(color: AppTheme.grey, fontSize: 13),
                ),
              ],
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SelectableText(
                body,
                style: TextStyle(
                  color: AppTheme.softWhite,
                  fontSize: 16,
                  height: 1.65,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
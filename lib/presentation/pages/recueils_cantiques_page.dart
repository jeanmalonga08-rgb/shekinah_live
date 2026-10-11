import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/recueil_cantique.dart';
import '../widgets/library_offline_download_helper.dart';
import '../widgets/sht_widgets.dart';

class RecueilsCantiquesPage extends ConsumerWidget {
  const RecueilsCantiquesPage({super.key});

  static final _items = <RecueilCantique>[
    RecueilCantique(
      id: 'recueil_bouclier_david',
      title: 'Chants Bouclier De David',
      pdfUrl:
          '${AppConstants.websiteUrl}/docs/Chants Bouclier de David 2020.pdf',
      coverUrl: '${AppConstants.websiteUrl}/images/docs/harp-0.png',
    ),
    RecueilCantique(
      id: 'recueil_crois_seulement',
      title: 'Crois Seulement',
      pdfUrl:
          '${AppConstants.recueilsBlobBaseUrl}/Cantiques%20Crois%20seulement.pdf',
      coverUrl: '${AppConstants.websiteUrl}/images/docs/songbook-1.jpg',
    ),
    RecueilCantique(
      id: 'recueil_hosana',
      title: 'Hosana',
      pdfUrl: '${AppConstants.recueilsBlobBaseUrl}/Cantiques%20Hosana.pdf',
      coverUrl: '${AppConstants.websiteUrl}/images/docs/songbook-1.jpg',
    ),
    RecueilCantique(
      id: 'recueil_pene_na_yo',
      title: 'Pene Na Yo',
      pdfUrl:
          '${AppConstants.recueilsBlobBaseUrl}/Cantique%20Pene%20Na%20Yo.pdf',
      coverUrl: '${AppConstants.websiteUrl}/images/docs/songbook-1.jpg',
    ),
    RecueilCantique(
      id: 'recueil_only_believe',
      title: 'Only Believe (En)',
      pdfUrl: '${AppConstants.recueilsBlobBaseUrl}/Only%20Believe.pdf',
      coverUrl: '${AppConstants.websiteUrl}/images/docs/songbook-2.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Recueils de cantiques')),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.64,
        ),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return _RecueilCard(item: item);
        },
      ),
    );
  }
}

class _RecueilCard extends ConsumerWidget {
  const _RecueilCard({required this.item});

  final RecueilCantique item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShtCard(
      onTap: () => openLibraryPdf(
        context,
        ref,
        title: item.title,
        pdfUrl: item.pdfUrl,
        category: OfflineMediaCategory.recueilCantique,
        sourceId: item.id,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.coverUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => _fallback(),
                errorWidget: (_, _, _) => _fallback(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => saveLibraryPdfOffline(
                    context,
                    ref,
                    category: OfflineMediaCategory.recueilCantique,
                    sourceId: item.id,
                    title: item.title,
                    subtitle: 'Recueil de chants',
                    pdfUrl: item.pdfUrl,
                    thumbnailUrl: item.coverUrl,
                  ),
                  icon: const Icon(
                    Icons.download_for_offline_outlined,
                    size: 18,
                  ),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppTheme.surfaceElevated,
      alignment: Alignment.center,
      child: Icon(
        Icons.menu_book_outlined,
        color: AppTheme.accentOnSurface,
        size: 34,
      ),
    );
  }
}

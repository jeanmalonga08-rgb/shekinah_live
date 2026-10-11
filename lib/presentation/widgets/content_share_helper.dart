import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/platform/local_file.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/cantique.dart';
import '../../domain/entities/multimedia_video.dart';
import '../../domain/entities/offline_media.dart';
import '../../domain/entities/predication.dart';

Rect? _shareOrigin(BuildContext context) {
  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.hasSize) return null;
  return renderObject.localToGlobal(Offset.zero) & renderObject.size;
}

Future<void> shareTextContent(
  BuildContext context, {
  required String text,
  required String subject,
}) async {
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: subject,
      sharePositionOrigin: _shareOrigin(context),
    ),
  );
}

String buildBranhamPredicationShareText({
  required String title,
  required String code,
  required String location,
  required String appInvitation,
}) {
  final details = [
    'William Branham · $code',
    if (location.isNotEmpty) location,
  ].join('\n');

  return '$title\n\n$details\n\n$appInvitation';
}

Future<void> sharePredication(
  BuildContext context,
  Predication predication,
) async {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context);
  final dateLabel = formatLongDate(predication.date, locale);
  final dateLine =
      '$dateLabel · ${predicationTypeLabel(l10n, predication.type)} · ${predicationTimeLabel(l10n, predication.timeType)}';

  await shareTextContent(
    context,
    text: l10n.sharePredicationBody(
      predicationDisplayTitle(l10n, predication),
      predication.displayPreacher,
      dateLine,
      AppConstants.archivesUrl,
      AppConstants.playStoreUrl,
    ),
    subject: l10n.sharePredicationSubject(
      predicationDisplayTitle(l10n, predication),
    ),
  );
}

Future<void> shareCantique(BuildContext context, Cantique cantique) async {
  final l10n = context.l10n;
  final subtitle = cantique.number > 0
      ? '${l10n.cantiquesNumber(cantique.number)} · ${cantique.displaySubtitle}'
      : cantique.displaySubtitle;

  await shareTextContent(
    context,
    text: l10n.shareCantiqueBody(
      cantiqueDisplayTitle(l10n, cantique),
      subtitle,
      AppConstants.appName,
      AppConstants.playStoreUrl,
      AppConstants.cantiquesUrl,
    ),
    subject: l10n.shareCantiqueSubject(cantiqueDisplayTitle(l10n, cantique)),
  );
}

Future<void> shareOfflineMediaInfo(
  BuildContext context,
  OfflineMediaItem item,
) async {
  final l10n = context.l10n;
  if (!context.mounted) return;

  final appInvitation = l10n.shareAppMessage(
    AppConstants.appName,
    AppConstants.playStoreUrl,
    AppConstants.websiteUrl,
  );

  await shareTextContent(
    context,
    text: '${l10n.shareOfflineBody(
      offlineCategoryLabel(l10n, item.category),
      item.title,
      item.subtitle,
      offlineFormatLabel(l10n, item.format),
      AppConstants.appName,
      AppConstants.playStoreUrl,
      AppConstants.websiteUrl,
    )}\n\n$appInvitation',
    subject: item.title,
  );
}

/// Partage uniquement le fichier local (menu « Partager le fichier »).
Future<void> shareOfflineMediaFile(
  BuildContext context,
  OfflineMediaItem item,
) async {
  final l10n = context.l10n;
  final path = item.localPath;
  final fileExists = path.isNotEmpty && await localFileExists(path);
  if (!context.mounted) return;

  if (!fileExists) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.offlineFileNotFound)),
    );
    return;
  }

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(path, name: _fileNameFor(item))],
      subject: item.title,
      sharePositionOrigin: _shareOrigin(context),
    ),
  );
}

String _fileNameFor(OfflineMediaItem item) {
  final path = item.localPath.replaceAll('\\', '/');
  final slash = path.lastIndexOf('/');
  if (slash >= 0 && slash < path.length - 1) {
    return path.substring(slash + 1);
  }
  final ext = switch (item.format) {
    OfflineMediaFormat.audio => '.mp3',
    OfflineMediaFormat.video => '.mp4',
    OfflineMediaFormat.pdf => '.pdf',
  };
  return '${item.sourceId}$ext';
}

Future<void> showOfflineFileActions(
  BuildContext context,
  OfflineMediaItem item,
) async {
  final l10n = context.l10n;
  final path = item.localPath;
  if (path.isEmpty || !await localFileExists(path)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.offlineFileNotFound)),
      );
    }
    return;
  }

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  l10n.offlineFileActions,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.share_outlined, color: AppTheme.accentOnSurface),
                title: Text(
                  l10n.offlineShareFile,
                  style: TextStyle(color: AppTheme.white),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await shareOfflineMediaFile(context, item);
                },
              ),
              if (canRevealLocalFileInExplorer)
                ListTile(
                  leading: Icon(
                    Icons.folder_open_outlined,
                    color: AppTheme.accentOnSurface,
                  ),
                  title: Text(
                    l10n.offlineShowInExplorer,
                    style: TextStyle(color: AppTheme.white),
                  ),
                  subtitle: Text(
                    localFileParentPath(path) ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.grey, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final ok = await revealLocalFileInExplorer(path);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? l10n.offlineFileRevealed
                              : l10n.offlineFileLocationUnavailable,
                        ),
                      ),
                    );
                  },
                )
              else
                ListTile(
                  leading: Icon(
                    Icons.folder_outlined,
                    color: AppTheme.accentOnSurface,
                  ),
                  title: Text(
                    l10n.offlineShowInExplorer,
                    style: TextStyle(color: AppTheme.white),
                  ),
                  subtitle: Text(
                    l10n.offlineMobileFileHint,
                    style: TextStyle(color: AppTheme.grey, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await shareOfflineMediaFile(context, item);
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> shareMultimediaVideo(
  BuildContext context,
  MultimediaVideo video,
) async {
  await shareTextContent(
    context,
    text:
        '${video.title}\n${video.category.name}\n${AppConstants.cantiquesUrl}\n${AppConstants.playStoreUrl}',
    subject: video.title,
  );
}

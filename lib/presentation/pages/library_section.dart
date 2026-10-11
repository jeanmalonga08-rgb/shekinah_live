import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';

enum LibrarySection { home, pepites, publication }

extension LibrarySectionX on LibrarySection {
  String get url {
    switch (this) {
      case LibrarySection.home:
        return AppConstants.libraryUrl;
      case LibrarySection.pepites:
        return AppConstants.libraryPepitesUrl;
      case LibrarySection.publication:
        return AppConstants.shekinahPublicationLibraryUrl;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case LibrarySection.home:
        return l10n.libraryHome;
      case LibrarySection.pepites:
        return l10n.libraryPepites;
      case LibrarySection.publication:
        return l10n.libraryPublication;
    }
  }

  static LibrarySection? fromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final normalized =
        url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    if (normalized == AppConstants.shekinahPublicationLibraryUrl) {
      return LibrarySection.publication;
    }
    if (normalized == AppConstants.libraryPepitesUrl) {
      return LibrarySection.pepites;
    }
    if (normalized == AppConstants.libraryUrl) {
      return LibrarySection.home;
    }
    return null;
  }
}

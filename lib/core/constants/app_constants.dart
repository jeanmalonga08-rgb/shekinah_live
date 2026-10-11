class AppConstants {
  static const String androidApplicationId = 'com.shekinah.tabernacle';

  static const String appName = 'Shekinah Tabernacle';
  static const String appShortName = 'Shekinah';
  static const String appVersion = '5.0.0';
  static const String templeMoriahName = 'Temple Moriah';
  static const String churchTagline = 'Interdénominationnelle';
  static const String pastorName = 'Pasteur Richard Diyoka';
  static const String pastorTitle = 'Pasteur Richard Diyoka Nsanguluja';
  static const String visionTitle = 'La Parole pour l\'Épouse';
  static const String visionMessage =
      'Nous croyons au Message prêché par William Marrion Branham, '
      'accomplissant Malachie 4:5-6. À travers le Cri, ce Message '
      'appelle une Épouse à se préparer à la venue de notre Seigneur Jésus-Christ.';
  static const String scriptureBanner =
      'Malachie 4:4-6  ·  Luc 17:30  ·  Apocalypse 10:1-7';
  static const String assemblyAddress =
      '18 Boulevard Lumumba, Matete — Kinshasa, RDC';
  static const String assemblyEmail = 'shekinahrdc@gmail.com';
  static const List<String> assemblyAddressLines = [
    '18 Boulevard Lumumba, Matete',
    'B.P. 10.493 KINSHASA',
    'RÉPUBLIQUE DÉMOCRATIQUE DU CONGO',
  ];
  /// Coordonnées GPS Temple Moriah / Shekinah Tabernacle (Matete).
  static const double assemblyLatitude = -4.387079511126889;
  static const double assemblyLongitude = 15.363005905559781;
  static const String assemblyMapQuery =
      '$assemblyLatitude,$assemblyLongitude';

  /// Aperçu carte (OSM) — fiable en WebView sans clé Google Embed API.
  static String get assemblyMapEmbedUrl {
    const d = 0.006;
    final minLon = assemblyLongitude - d;
    final minLat = assemblyLatitude - d;
    final maxLon = assemblyLongitude + d;
    final maxLat = assemblyLatitude + d;
    return 'https://www.openstreetmap.org/export/embed.html'
        '?bbox=$minLon%2C$minLat%2C$maxLon%2C$maxLat'
        '&layer=mapnik'
        '&marker=$assemblyLatitude%2C$assemblyLongitude';
  }

  static const String assemblyMapLaunchUrl =
      'https://www.google.com/maps/search/?api=1&query=$assemblyLatitude,$assemblyLongitude';

  static const String developerEmail = 'jeanmalonga08@gmail.com';
  static const String developerPhoneDisplay = '+243 846 656 910';
  static const String developerPhoneE164 = '+243846656910';
  static const String developerWhatsAppPhone = '243846656910';

  static const String liveStreamUrl = 'https://shekinahgospel.org/live';
  static const String websiteUrl = 'https://shekinahgospel.org';
  static const String androidPackageId = 'com.shekinah.tabernacle';
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageId';
  static const String archivesUrl = 'https://shekinahgospel.org/archives';
  static const String cantiquesUrl = 'https://shekinahgospel.org/multimedia';
  static const String communiqueDetailsUrl =
      'https://donation.shekinahgospel.org';
  static const String donationUrl = 'https://donation.shekinahgospel.org';
  /// Ancre formulaire sur le site donation (référence ; l'app ouvre Flexpaie).
  static const String moriahDonationFormUrl =
      'https://donation.shekinahgospel.org/#favorite';
  /// Formulaire Flexpaie — campagne reconstruction Temple Moriah.
  static const String flexpaieDonationUrl = 'https://shekinah.flexpaie.com';
  static const String contactUrl = 'https://shekinahgospel.org/contact/';
  static const String shekinahPublicationUrl =
      'https://shekinahgospel.org/shekinah-publication';
  static const String shekinahPublicationLibraryUrl =
      'https://library.shekinahgospel.org/shekinah-publication';
  static const String libraryPepitesUrl =
      'https://library.shekinahgospel.org/library';
  static const String libraryUrl = 'https://library.shekinahgospel.org';
  static const String libraryBookDataUrl =
      'https://shekinahlibrary.blob.core.windows.net/librarydata/rawdata/book-data.json';
  static const String libraryMessageDataUrl =
      'https://documentmanagerfunc.azurewebsites.net/api/documentReader/groupByYear';
  static const String libraryMessageByYearUrl =
      'https://documentmanagerfunc.azurewebsites.net/api/messageDocument/getByYear';
  static const String libraryAssetsBaseUrl =
      'https://library.shekinahgospel.org/';
  static const String fondationShekinahUrl =
      'https://shekinahgospel.org/assemblee';
  static const String assemblyUrl = 'https://shekinahgospel.org/assemblee';
  static const String assemblyPastorUrl =
      'https://shekinahgospel.org/assemblee/pastor';
  static const String assemblySisterChurchesUrl =
      'https://shekinahgospel.org/assemblee/other-churches';
  static const String ecamoUrl = 'https://shekinahgospel.org/ecamo';
  static const String williamBranhamUrl =
      'https://shekinahgospel.org/william-branham';
  static const String ecamoBannerAsset = 'assets/images/BANIERE_ECAMO.png';
  static const String broBranhamAsset = 'assets/images/bro-branham.jpg';
  static const String pastorAsset = 'assets/images/Pastor.png';
  static const String logoShekinahAsset = 'assets/images/logo-shekinah.png';
  static const String fondationShekinahAsset =
      'assets/images/FONDATION_SHEKINAH.png';
  static const String shekinahPublicationsAsset =
      'assets/images/SHEKINAH_PUBLICATIONS.jpg';
  static const String shekinahPublicationEagleAsset =
      'assets/images/eagle_0.png';
  static const String logoUrl =
      'https://shekinahgospel.org/images/logo-trans.png';
  static const String logoAsset = 'assets/logo/logo-trans.png';

  /// Photos locales — Temple Moriah (avant / après le feu)
  static const String moriahMainEntranceBeforeAsset =
      'assets/images/main-entrance-before.png';
  static const String moriahSanctuaryBeforeAsset =
      'assets/images/sanctuary-before.png';
  static const String moriahMainEntranceAfterAsset =
      'assets/images/main-entrance-after.jpg';
  static const String moriahSanctuaryAfterAsset =
      'assets/images/sanctuary-after.jpeg';
  static const String moriahBalconyAfterAsset =
      'assets/images/balcony-after.jpeg';
  static const String moriahRoofAfterAsset = 'assets/images/roof-after.jpeg';
  static const String moriahTempleBeforeVideoAsset =
      'assets/videos/temple-before.mp4';
  static const String moriahTempleAfterVideoAsset =
      'assets/videos/temple-after.mp4';

  /// Backend public du site (mêmes sources que shekinahgospel.org/archives).
  static const String supabaseUrl = 'https://lfyeqcvhspiivukacgzw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmeWVxY3Zoc3BpaXZ1a2FjZ3p3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODIwMjksImV4cCI6MjA2MTU1ODAyOX0.aSasZEOkzSls-u4qvAPR597avCMDot_cPs0QIDzhQPM';
  static const String sermonArchivesTable = 'sermon-archives';
  static const String servicesLiveTable = 'services-live';

  /// Dossier Vimeo « worships » du site (chants d'ensemble vidéo).
  static const String vimeoWorshipsProjectId = '1263373';
  static const String multimediaEagleThumbUrl =
      'https://shekinahgospel.org/images/music/eagle_0.png';
  static const String recueilsBlobBaseUrl =
      'https://shekinahwebstorage.blob.core.windows.net/media-docs';

  /// Chaîne YouTube (Fr. Dauphin Elalanga) — cantiques individuels / ensemble.
  static const String youtubeCantiquesChannelId = 'UCgKzKgtqjjX8vTdO7Eb3ZlA';
  static const int predicationsPageSize = 20;
  static const int cantiquesPageSize = 20;

  static const int connectionTimeout = 45000;
  static const int receiveTimeout = 60000;

  /// Rafraîchissement Supabase pendant un live (détection changement videoId / goLive).
  static const Duration liveRefreshIntervalLive = Duration(seconds: 30);

  /// Rafraîchissement hors live pour détecter le début d'un culte.
  static const Duration liveRefreshIntervalOffline = Duration(seconds: 90);

  /// API notifications push + feed in-app (production LWS).
  static const String notificationsApiBaseUrl =
      'https://api-live.asdc-rdc.org';

  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 '
      'ShekinahLive/1.0.0';

  static const double cardRadius = 16;
  static const double buttonRadius = 12;
}

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shekinah_live/domain/entities/communique.dart';
import 'package:shekinah_live/domain/entities/live_status.dart';
import 'package:shekinah_live/domain/entities/predication.dart';
import 'package:shekinah_live/domain/repositories/live_stream_repository.dart';
import 'package:shekinah_live/domain/usecases/check_live_status_usecase.dart';
import 'package:shekinah_live/l10n/app_localizations.dart';
import 'package:shekinah_live/presentation/pages/home_page.dart';
import 'package:shekinah_live/presentation/pages/login_page.dart';
import 'package:shekinah_live/presentation/providers/app_update_provider.dart';
import 'package:shekinah_live/presentation/providers/communique_provider.dart';
import 'package:shekinah_live/presentation/providers/live_stream_provider.dart';
import 'package:shekinah_live/presentation/providers/moriah_campaign_provider.dart';
import 'package:shekinah_live/presentation/providers/predication_provider.dart';
import 'package:shekinah_live/presentation/widgets/sht_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Accueil opens the multilingual Branham audio catalog', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communiqueProvider.overrideWith(_EmptyCommuniqueNotifier.new),
          recentMonthPredicationsProvider.overrideWith(
            (ref) async => const <Predication>[],
          ),
          liveStreamProvider.overrideWith(
            (ref) => LiveStreamNotifier(
              CheckLiveStatusUseCase(_OfflineLiveStreamRepository()),
            ),
          ),
          appUpdatePromptProvider.overrideWith((ref) async => null),
          moriahCampaignActiveProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          locale: const Locale('fr', 'FR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const HomePage(),
        ),
      ),
    );

    const description =
        'Tous les sermons audio du prophète William Marrion Branham, disponibles en plusieurs langues.';
    final descriptionFinder = find.text(description);
    await tester.scrollUntilVisible(
      descriptionFinder,
      250,
      scrollable: find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      ).first,
    );
    expect(descriptionFinder, findsOneWidget);

    final exploreButton = find.widgetWithText(TextButton, 'Explorer');
    expect(exploreButton, findsOneWidget);
    expect(tester.widget<TextButton>(exploreButton).onPressed, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('Double-tapping the home logo opens the login form', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communiqueProvider.overrideWith(_EmptyCommuniqueNotifier.new),
          recentMonthPredicationsProvider.overrideWith(
            (ref) async => const <Predication>[],
          ),
          liveStreamProvider.overrideWith(
            (ref) => LiveStreamNotifier(
              CheckLiveStatusUseCase(_OfflineLiveStreamRepository()),
            ),
          ),
          appUpdatePromptProvider.overrideWith((ref) async => null),
          moriahCampaignActiveProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          locale: const Locale('fr', 'FR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const HomePage(),
        ),
      ),
    );

    final logo = find.byType(AppLogo);
    await tester.tap(logo);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(logo);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 6));
  });
}

class _EmptyCommuniqueNotifier extends CommuniqueNotifier {
  @override
  Future<List<Communique>> build() async => const [];
}

class _OfflineLiveStreamRepository implements LiveStreamRepository {
  @override
  Future<Either<String, LiveStreamEntity>> checkLiveStatus() async =>
      const Left('offline');

  @override
  String getStreamUrl() => '';

  @override
  Future<bool> isLiveCurrently() async => false;

  @override
  Future<Either<String, LiveStreamEntity>> refreshLiveStatus() async =>
      const Left('offline');
}
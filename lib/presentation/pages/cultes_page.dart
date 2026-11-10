import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_format.dart';
import '../../core/theme/app_theme.dart';
import '../providers/church_program_provider.dart';
import '../widgets/sht_widgets.dart';

class CultesPage extends ConsumerWidget {
  const CultesPage({super.key});

  static const _weekdays = [
    DateTime.sunday,
    DateTime.wednesday,
    DateTime.thursday,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final programAsync = ref.watch(churchProgramProvider);
    final now = DateTime.now();
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cultesTitle),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(churchProgramDataSourceProvider).clearCache();
              ref.invalidate(churchProgramProvider);
            },
          ),
        ],
      ),
      body: programAsync.when(
        data: (program) {
          final services = upcomingChurchServices(program);
          if (services.isEmpty) {
            return _buildFallback(l10n, now);
          }
          return _buildRemoteList(l10n, locale, services, now);
        },
        loading: () => _buildFallback(l10n, now),
        error: (_, _) => _buildFallback(l10n, now),
      ),
    );
  }

  Widget _buildRemoteList(
    AppLocalizations l10n,
    Locale locale,
    List<UpcomingChurchService> services,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(l10n: l10n),
        const SizedBox(height: 16),
        ...services.map(
          (service) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ServiceCard(
              title: formatLongDate(service.dateTime, locale),
              time: service.entry.time,
              periodLabel: worshipPeriodLabel(l10n, service.entry.period),
              label: service.entry.label,
              isToday:
                  DateTime(
                    service.dateTime.year,
                    service.dateTime.month,
                    service.dateTime.day,
                  ) ==
                  today,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _VisionCard(l10n: l10n),
      ],
    );
  }

  Widget _buildFallback(
    AppLocalizations l10n,
    DateTime now,
  ) {
    final schedule = worshipScheduleEntries(l10n);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderCard(l10n: l10n),
        const SizedBox(height: 16),
        ...List.generate(schedule.length, (index) {
          final entry = schedule[index];
          final weekday = _weekdays[index];
          final isToday = weekday == now.weekday;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ServiceCard(
              title: l10n.cultesService(entry.day),
              time: entry.time,
              isToday: isToday,
            ),
          );
        }),
        const SizedBox(height: 8),
        _VisionCard(l10n: l10n),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.assemblyAddress,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeScriptureBanner,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentOnSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _VisionCard extends StatelessWidget {
  const _VisionCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.visionTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.accentOnSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.visionMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.title,
    required this.time,
    required this.isToday,
    this.periodLabel,
    this.label,
  });

  final String title;
  final String time;
  final bool isToday;
  final String? periodLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ShtCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isToday)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Chip(
                      label: Text(l10n.today),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (label != null && label!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Chip(
                      label: Text(label!),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.worshipAt(time),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (periodLabel != null)
                  Text(
                    periodLabel!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  AppConstants.assemblyAddress,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.royalBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: AppTheme.goldOnSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

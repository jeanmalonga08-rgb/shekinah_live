import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/sht_widgets.dart';

class CultesPage extends StatelessWidget {
  const CultesPage({super.key});

  static const _weekdays = [
    DateTime.sunday,
    DateTime.wednesday,
    DateTime.thursday,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final schedule = worshipScheduleEntries(l10n);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cultesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ShtCard(
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
          ),
          const SizedBox(height: 16),
          ...List.generate(schedule.length, (index) {
            final entry = schedule[index];
            final weekday = _weekdays[index];
            final isToday = weekday == now.weekday;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShtCard(
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
                          Text(
                            l10n.cultesService(entry.day),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.worshipAt(entry.time),
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
                        entry.time,
                        style: TextStyle(
                          color: AppTheme.goldOnSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          ShtCard(
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
          ),
        ],
      ),
    );
  }
}

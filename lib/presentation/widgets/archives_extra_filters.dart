import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/predication_filter_constants.dart';
import '../../core/l10n/entity_labels.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/predication_provider.dart';
import '../widgets/sht_widgets.dart';

Future<void> showArchivesExtraFiltersSheet(
  BuildContext context,
  WidgetRef ref, {
  required PredicationQuery current,
  required ValueChanged<PredicationQuery> onApply,
}) async {
  final l10n = context.l10n;
  var draftType = current.type ?? PredicationFilterConstants.all;
  var draftTimeType = current.timeType ?? PredicationFilterConstants.all;
  var draftLocation = current.location ?? PredicationFilterConstants.all;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.filterMore,
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(Icons.close, color: AppTheme.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ShtFilterDropdown<String>(
                    label: l10n.filterType,
                    icon: Icons.category_outlined,
                    padding: EdgeInsets.zero,
                    value: draftType,
                    items: [
                      DropdownMenuItem(
                        value: PredicationFilterConstants.all,
                        child: Text(l10n.allItems),
                      ),
                      ...PredicationFilterConstants.types.map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(predicationTypeLabel(l10n, type)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => draftType = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  ShtFilterDropdown<String>(
                    label: l10n.filterTime,
                    icon: Icons.schedule_outlined,
                    padding: EdgeInsets.zero,
                    value: draftTimeType,
                    items: [
                      DropdownMenuItem(
                        value: PredicationFilterConstants.all,
                        child: Text(l10n.allItems),
                      ),
                      ...PredicationFilterConstants.timeTypes.map(
                        (timeType) => DropdownMenuItem(
                          value: timeType,
                          child: Text(predicationTimeLabel(l10n, timeType)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => draftTimeType = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final locationsAsync =
                          ref.watch(predicationLocationsProvider);
                      return locationsAsync.when(
                        data: (catalog) {
                          final locations = catalog.labels;
                          if (locations.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final activeLocation =
                              locations.contains(draftLocation) ||
                                      draftLocation ==
                                          PredicationFilterConstants.all
                                  ? draftLocation
                                  : PredicationFilterConstants.all;
                          return ShtFilterDropdown<String>(
                            label: l10n.filterLocation,
                            icon: Icons.place_outlined,
                            padding: EdgeInsets.zero,
                            value: activeLocation,
                            items: [
                              DropdownMenuItem(
                                value: PredicationFilterConstants.all,
                                child: Text(l10n.allItems),
                              ),
                              ...locations.map(
                                (location) => DropdownMenuItem(
                                  value: location,
                                  child: Text(
                                    location,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setSheetState(() => draftLocation = value);
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              draftType = PredicationFilterConstants.all;
                              draftTimeType = PredicationFilterConstants.all;
                              draftLocation = PredicationFilterConstants.all;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.softWhite,
                            side: BorderSide(
                              color: AppTheme.accentOnSurface
                                  .withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(l10n.filterResetExtra),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            onApply(
                              current.copyWith(
                                type: draftType == PredicationFilterConstants.all
                                    ? null
                                    : draftType,
                                timeType: draftTimeType ==
                                        PredicationFilterConstants.all
                                    ? null
                                    : draftTimeType,
                                location: draftLocation ==
                                        PredicationFilterConstants.all
                                    ? null
                                    : draftLocation,
                                clearType:
                                    draftType == PredicationFilterConstants.all,
                                clearTimeType: draftTimeType ==
                                    PredicationFilterConstants.all,
                                clearLocation: draftLocation ==
                                    PredicationFilterConstants.all,
                              ),
                            );
                            Navigator.pop(sheetContext);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.ctaBackground,
                            foregroundColor: AppTheme.ctaForeground,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(l10n.filterApplyExtra),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

String archivesExtraFilterSummary(
  AppLocalizations l10n,
  PredicationQuery query,
) {
  final parts = <String>[];
  final type = query.type;
  if (type != null && type.isNotEmpty) {
    parts.add(predicationTypeLabel(l10n, type));
  }
  final timeType = query.timeType;
  if (timeType != null && timeType.isNotEmpty) {
    parts.add(predicationTimeLabel(l10n, timeType));
  }
  final location = query.location;
  if (location != null && location.isNotEmpty) {
    parts.add(location);
  }
  return parts.join(' · ');
}

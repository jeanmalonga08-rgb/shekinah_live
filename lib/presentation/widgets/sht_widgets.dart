import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_sync.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showShadow = true,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceElevated,
        border: Border.all(
          color: AppTheme.accentOnSurface.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppTheme.accentOnSurface.withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(
            AppConstants.logoAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => ColoredBox(
              color: AppTheme.surfaceElevated,
              child: Icon(
                Icons.church,
                color: AppTheme.accentOnSurface,
                size: size * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShtCard extends StatelessWidget {
  const ShtCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: AppTheme.surface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class ShtSectionHeader extends StatelessWidget {
  const ShtSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentOnSurface,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Filtre déroulant (sélection seule, sans saisie / recherche).
class ShtFilterDropdown<T> extends StatelessWidget {
  const ShtFilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.icon = Icons.filter_list_rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  static String labelOf<T>(DropdownMenuItem<T> item) {
    final child = item.child;
    if (child is Text) return child.data ?? '';
    return item.value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    ThemeSync.watch(context);
    final entries = <DropdownMenuEntry<T>>[
      for (final item in items)
        if (item.value != null)
          DropdownMenuEntry<T>(
            value: item.value as T,
            label: labelOf(item),
          ),
    ];

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.maxWidth.isFinite ? constraints.maxWidth : null;
          return DropdownMenu<T>(
            // Resync le texte affiché quand la valeur parent change.
            key: ValueKey<Object?>('sht-filter-$label-$value'),
            width: width,
            initialSelection: value,
            label: Text(label),
            leadingIcon: Icon(icon, color: AppTheme.brandAccent, size: 18),
            trailingIcon:
                Icon(Icons.expand_more_rounded, color: AppTheme.grey, size: 18),
            selectedTrailingIcon:
                Icon(Icons.expand_less_rounded, color: AppTheme.grey, size: 18),
            enableFilter: false,
            requestFocusOnTap: false,
            onSelected: onChanged,
            dropdownMenuEntries: entries,
            textStyle: TextStyle(
              color: AppTheme.white,
              fontWeight: FontWeight.w500,
            ),
            inputDecorationTheme: InputDecorationTheme(
              isDense: true,
              filled: true,
              fillColor: AppTheme.surface,
              labelStyle: TextStyle(color: AppTheme.muted),
              floatingLabelStyle: TextStyle(color: AppTheme.muted),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: AppTheme.brandAccent.withValues(alpha: 0.55),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            menuStyle: MenuStyle(
              backgroundColor:
                  WidgetStatePropertyAll(AppTheme.surfaceElevated),
              surfaceTintColor:
                  const WidgetStatePropertyAll(Colors.transparent),
              maximumSize: WidgetStatePropertyAll(
                Size(width ?? 360, 320),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final liveLabel = context.l10n.homeLive.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.live,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            liveLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../pages/notifications_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

/// Barre supérieure : logo + notifications + profil + paramètres.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBrand;
  final List<Widget>? extraActions;

  const AppTopBar({
    super.key,
    this.title,
    this.showBrand = true,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentOnSurface.withValues(alpha: 0.18),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          if (showBrand) ...[
            _BrandMark(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title ?? AppConstants.appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.onDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    l10n.churchTagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.accentOnSurface.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Expanded(
              child: Text(
                title ?? '',
                style: TextStyle(color: AppTheme.onDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          ...?extraActions,
          _TopAction(
            icon: Icons.notifications_none_rounded,
            tooltip: l10n.notificationsTitle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          _TopAction(
            icon: Icons.person_outline_rounded,
            tooltip: l10n.homeMyProfile,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          _TopAction(
            icon: Icons.settings_outlined,
            tooltip: l10n.settingsTitle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.accentOnSurface.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalBlue.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AppConstants.logoAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => ColoredBox(
            color: AppTheme.surfaceElevated,
            child: Icon(Icons.church, color: AppTheme.accentOnSurface, size: 22),
          ),
        ),
      ),
    );
  }
}

class _TopAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Tooltip(
            message: tooltip,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.onDark.withValues(alpha: 0.04),
              ),
              child: Icon(icon, color: AppTheme.onDark.withValues(alpha: 0.9), size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

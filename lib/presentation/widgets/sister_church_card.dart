import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';
import '../../data/sister_churches_data.dart';
import 'sht_widgets.dart';

class SisterChurchCard extends StatelessWidget {
  const SisterChurchCard({super.key, required this.church});

  final SisterChurch church;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final flagUrl = sisterChurchFlagUrl(church.countryCode);

    return ShtCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (flagUrl != null) ...[
                _FlagBadge(url: flagUrl),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppTheme.accentOnSurface,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.notreEgliseSisterChurchPastor,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.grey,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      church.pastors,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppTheme.accentOnSurface.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  church.address,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                      ),
                ),
              ),
            ],
          ),
          if (church.emails.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: church.emails
                  .map(
                    (email) => _ContactChip(
                      icon: Icons.mail_outline,
                      label: email,
                      onTap: () => _launch(Uri.parse('mailto:$email')),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (church.phones.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: church.phones
                  .map(
                    (phone) => _ContactChip(
                      icon: Icons.phone_outlined,
                      label: _formatPhone(phone),
                      onTap: () => _launch(Uri.parse('tel:$phone')),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPhone(String phone) {
    if (phone.startsWith('+243') && phone.length >= 12) {
      return '+243 ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    if (phone.startsWith('+244') && phone.length >= 12) {
      return '+244 ${phone.substring(4, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    if (phone.startsWith('+32') && phone.length >= 11) {
      return '+32 ${phone.substring(3, 6)} ${phone.substring(6, 9)} ${phone.substring(9)}';
    }
    if (phone.startsWith('+221') && phone.length >= 12) {
      return '+221 ${phone.substring(4, 7)} ${phone.substring(7, 10)} ${phone.substring(10)}';
    }
    return phone;
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
        ),
        border: Border.all(
          color: AppTheme.accentOnSurface.withValues(alpha: 0.45),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: 38,
          height: 26,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            Icons.flag_outlined,
            color: AppTheme.accentOnSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.accentOnSurface.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppTheme.accentOnSurface),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.accentOnSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

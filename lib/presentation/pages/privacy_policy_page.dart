import 'package:flutter/material.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.surface,
              elevation: AppTheme.isLight ? 0 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOnSurface.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.privacy_tip,
                            color: AppTheme.accentOnSurface,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.appName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                l10n.privacyVersion,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.privacyDeveloper,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      l10n.privacyContact,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.accentOnSurface,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              l10n.privacyNoDataCollection,
              Icons.block,
              [
                l10n.privacyNoDataItem1,
                l10n.privacyNoDataItem2,
                l10n.privacyNoDataItem3,
                l10n.privacyNoDataItem4,
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              l10n.privacyWhatWeDontDo,
              Icons.check_circle,
              [
                l10n.privacyDontTrack,
                l10n.privacyDontAds,
                l10n.privacyDontSignup,
                l10n.privacyDontDatabase,
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              l10n.privacyHowItWorks,
              Icons.search,
              [
                l10n.privacyStreaming,
                l10n.privacyArchives,
                l10n.privacySupport,
                l10n.privacyLocalStorage,
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              l10n.privacyProtectionTitle,
              Icons.security,
              [
                l10n.privacyProtectionItem1,
                l10n.privacyProtectionItem2,
                l10n.privacyProtectionItem3,
                l10n.privacyProtectionItem4,
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              l10n.privacyYourRightsTitle,
              Icons.person,
              [
                l10n.privacyYourRightsItem1,
                l10n.privacyYourRightsItem2,
                l10n.privacyYourRightsItem3,
                l10n.privacyYourRightsItem4,
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              l10n.privacyPermissionsTitle,
              Icons.perm_device_information,
              [
                l10n.privacyPermissionsItem1,
                l10n.privacyPermissionsItem2,
                l10n.privacyPermissionsItem3,
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: AppTheme.surface,
              elevation: AppTheme.isLight ? 0 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.borderSubtle),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      l10n.privacyCommitmentTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.privacyCommitmentSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.privacyCommitmentFooter,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentOnSurface,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      color: AppTheme.surface,
      elevation: AppTheme.isLight ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.accentOnSurface, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.plusAbout),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.appName} v1.0.0',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.privacyAboutDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.privacyDeveloper,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentOnSurface,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.ok,
                style: TextStyle(color: AppTheme.accentOnSurface),
              ),
            ),
          ],
        );
      },
    );
  }
}

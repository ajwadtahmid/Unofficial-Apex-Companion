import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/api_constants.dart';
import '../../providers/api_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';
import 'widgets/cache_settings_section.dart';
import 'widgets/general_settings_section.dart';
import 'widgets/notification_settings_section.dart';
import 'widgets/stats_refresh_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.md),
        children: [
          const GeneralSettingsSection(),
          const SizedBox(height: AppTheme.md),
          const StatsRefreshSection(),
          const SizedBox(height: AppTheme.md),
          const NotificationSettingsSection(),
          const SizedBox(height: AppTheme.md),
          const CacheSettingsSection(),
          const SizedBox(height: AppTheme.md),

          // ── About & Resources ─────────────────────────────────────
          const SectionLabel(label: 'ABOUT & RESOURCES', icon: Icons.info_outline),
          SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow(
                  label: 'Version',
                  value: ref
                          .watch(packageInfoProvider)
                          .whenOrNull(data: (info) => info.version) ??
                      '—',
                ),
                const SizedBox(height: AppTheme.sm),
                const Text(
                  'Unofficial Apex Companion is an unofficial companion app. Not made by, affiliated with, or endorsed by Electronic Arts or Respawn Entertainment.',
                  style: TextStyle(color: AppTheme.muted, fontSize: 11, height: 1.4),
                ),
                const Divider(color: AppTheme.surface2, height: 24),
                const LinkRow(
                  label: 'apexlegendsstatus.com',
                  subtitle: 'Server status. You can check this website for more information.',
                  url: ApiConstants.apexStatusUrl,
                ),
                const Divider(color: AppTheme.surface2, height: 24),
                const LinkRow(
                  label: 'apexlegendsapi.com',
                  subtitle: 'Player stats & legend data are provided by this API.',
                  url: ApiConstants.apexApiUrl,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.xl),
        ],
      ),
    );
  }
}

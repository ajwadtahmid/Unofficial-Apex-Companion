import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/api_constants.dart';
import '../../../providers/navigation_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../utils/notifications.dart';
import '../../../utils/theme.dart';
import '../../../widgets/widgets.dart';

class GeneralSettingsSection extends ConsumerWidget {
  const GeneralSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(playerSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: 'ACCOUNT', icon: Icons.person_outline),
        SettingsCard(
          child: settings.isPlayerSet
              ? _PlayerInfoContent(settings: settings)
              : _NoPlayerContent(onTap: () => ref.read(currentTabProvider.notifier).setTab(1)),
        ),
      ],
    );
  }
}

class _PlayerInfoContent extends StatelessWidget {
  final PlayerSettings settings;
  const _PlayerInfoContent({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline, color: AppTheme.accent, size: 20),
            const SizedBox(width: AppTheme.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    ApiConstants.labelFor(settings.platform),
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.sm),
        const Divider(color: AppTheme.surface2),
        const SizedBox(height: AppTheme.sm),
        InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          onTap: () {
            Clipboard.setData(ClipboardData(text: settings.uid));
            context.showMessage(
              'UID copied',
              duration: const Duration(seconds: 2),
            );
          },
          child: Row(
            children: [
              const Text('UID', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Text(
                  settings.uid,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              const Icon(Icons.copy, size: 14, color: AppTheme.muted),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sm),
        const Divider(color: AppTheme.surface2),
        const SizedBox(height: AppTheme.xs),
        const Text(
          'To change your player, go to the Stats tab.',
          style: TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _NoPlayerContent extends StatelessWidget {
  final VoidCallback onTap;
  const _NoPlayerContent({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      onTap: onTap,
      child: const Row(
        children: [
          Icon(Icons.person_outline, color: AppTheme.muted, size: 20),
          SizedBox(width: AppTheme.sm),
          Text('No player set up', style: TextStyle(color: AppTheme.muted)),
          Spacer(),
          Text('Go to My Stats →', style: TextStyle(color: AppTheme.accent, fontSize: 13)),
        ],
      ),
    );
  }
}

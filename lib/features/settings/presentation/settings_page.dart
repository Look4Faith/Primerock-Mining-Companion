import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/providers.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(settingsServiceProvider).displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    await ref.read(settingsServiceProvider).setDisplayName(_nameController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name saved')),
      );
    }
  }

  void _showLegalDialog(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(body, style: const TextStyle(height: 1.5)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    final settings = ref.watch(settingsServiceProvider);
    final notifications = settings.notificationsEnabled;
    final language = settings.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageGradient(context)),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Appearance'),
            GlassCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                subtitle: Text(
                  darkMode
                      ? 'Black & gold (default)'
                      : 'Light cream & gold accents',
                ),
                value: darkMode,
                onChanged: (v) =>
                    ref.read(darkModeProvider.notifier).setDark(v),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Profile'),
            GlassCard(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _saveName,
                      child: const Text('Save name'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Preferences'),
            GlassCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notifications'),
                subtitle: const Text('Gold price reminders (coming soon)'),
                value: notifications,
                activeTrackColor: AppColors.gold.withValues(alpha: 0.5),
                activeThumbColor: AppColors.gold,
                onChanged: (v) async {
                  await settings.setNotificationsEnabled(v);
                  await ref.read(notificationServiceProvider).setEnabled(v);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Language'),
                subtitle: Text(_languageLabel(language)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gold),
                onTap: () => _showLanguagePicker(language),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'About'),
            GlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('About Primerock'),
                    trailing: const Icon(Icons.info_outline, color: AppColors.gold),
                    onTap: () => _showLegalDialog(
                      'About ${AppConstants.appName}',
                      '${AppConstants.companyName} builds practical tools for Zimbabwean '
                      'artisanal and small-scale miners. This companion app provides '
                      'offline calculators, gold price tracking, knowledge articles, '
                      'production records, and access to Primerock Laboratory services.\n\n'
                      'Version ${AppConstants.appVersion}',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.privacy_tip_outlined, color: AppColors.gold),
                    onTap: () => _showLegalDialog(
                      'Privacy Policy',
                      'Primerock Mining Companion stores your production records and '
                      'preferences locally on your device. We do not collect personal '
                      'data without your consent. Optional remote content updates fetch '
                      'public JSON files only. Contact details you use to reach Primerock '
                      'are handled according to standard business communication practices.',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Terms of Use'),
                    trailing: const Icon(Icons.description_outlined, color: AppColors.gold),
                    onTap: () => _showLegalDialog(
                      'Terms of Use',
                      'This app is provided for informational and record-keeping purposes. '
                      'Gold prices, calculator results, and assistant answers are estimates '
                      'and not financial or legal advice. Always verify assay results with '
                      'accredited laboratories. Primerock Solutions is not liable for '
                      'decisions made solely on app outputs.',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('App version'),
                    trailing: Text(
                      AppConstants.appVersion,
                      style: TextStyle(color: AppColors.accent(context)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(String code) {
    return switch (code) {
      'en' => 'English',
      'sn' => 'Shona (coming soon)',
      'nd' => 'Ndebele (coming soon)',
      _ => code,
    };
  }

  void _showLanguagePicker(String current) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.elevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select language',
                  style: TextStyle(
                    color: AppColors.accent(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              _LanguageTile(
                label: 'English',
                code: 'en',
                selected: current == 'en',
                enabled: true,
                onTap: () => _setLanguage(ctx, 'en'),
              ),
              _LanguageTile(
                label: 'Shona',
                code: 'sn',
                selected: current == 'sn',
                enabled: false,
                onTap: () {},
              ),
              _LanguageTile(
                label: 'Ndebele',
                code: 'nd',
                selected: current == 'nd',
                enabled: false,
                onTap: () {},
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setLanguage(BuildContext sheetContext, String code) async {
    await ref.read(settingsServiceProvider).setLanguageCode(code);
    if (mounted) setState(() {});
    if (sheetContext.mounted) Navigator.pop(sheetContext);
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.code,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String code;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: enabled ? null : const Text('Coming soon'),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.gold)
          : null,
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}

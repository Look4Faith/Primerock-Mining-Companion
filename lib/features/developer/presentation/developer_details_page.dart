import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/paynow_donate.dart';
import '../../../services/contact_launcher.dart';
import '../../../widgets/app_page_background.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';

/// Developer / support / donate — similar to “Developer Details” on hymn apps.
class DeveloperDetailsPage extends StatefulWidget {
  const DeveloperDetailsPage({super.key});

  @override
  State<DeveloperDetailsPage> createState() => _DeveloperDetailsPageState();
}

class _DeveloperDetailsPageState extends State<DeveloperDetailsPage> {
  double? _selectedAmount = 5;

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      final message = e is AppFailure ? e.message : 'Could not open link: $e';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _donate() async {
    await _run(() => ContactLauncher.openUrl(PaynowDonate.url(amountUsd: _selectedAmount)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Details'),
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
            GlassCard(
              child: Column(
                children: [
                  const BrandLogoBadge(
                    assetPath: AppConstants.logoAsset,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accentSoft(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(color: AppColors.textMuted(context)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Built for Zimbabwean miners — offline tools, FGR prices, '
                    'lab booking, and mining news.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.06, end: 0),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Developer',
              subtitle: 'Who builds and supports this app',
            ),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.business_outlined,
                    label: 'Company',
                    value: AppConstants.developerCompany,
                  ),
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Product',
                    value: AppConstants.companyName,
                  ),
                  const Divider(height: 20),
                  _InfoRow(
                    icon: Icons.place_outlined,
                    label: 'Base',
                    value: AppConstants.contactAddress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Support',
              subtitle: 'Talk to the developer or Primerock team',
            ),
            GlassCard(
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.call_outlined,
                    title: 'Call support',
                    subtitle: AppConstants.developerSupportPhone,
                    onTap: () => _run(
                      () => ContactLauncher.phone(AppConstants.developerSupportPhone),
                    ),
                  ),
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.chat_outlined,
                    title: 'WhatsApp developer',
                    subtitle: AppConstants.developerSupportWhatsApp,
                    onTap: () => _run(
                      () => ContactLauncher.whatsapp(
                        AppConstants.developerSupportWhatsApp,
                        message:
                            'Hello — I need support with Primerock Mining Companion.',
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.email_outlined,
                    title: 'Email support',
                    subtitle: AppConstants.developerSupportEmail,
                    onTap: () => _run(
                      () => ContactLauncher.email(
                        AppConstants.developerSupportEmail,
                        subject: 'Primerock Mining Companion — Support',
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.science_outlined,
                    title: 'Lab & bookings',
                    subtitle: 'Open Primerock contact / booking',
                    onTap: () => context.push('/contact'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Donate',
              subtitle: 'Support development via Paynow',
            ),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Optional donations help keep Primerock Mining Companion '
                    'free for miners. Paid securely through Paynow '
                    '(${AppConstants.developerCompany}).',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Suggested amount (USD)',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final amount in const [1.0, 2.0, 5.0, 10.0, 20.0])
                        ChoiceChip(
                          label: Text('\$${amount.toStringAsFixed(0)}'),
                          selected: _selectedAmount == amount,
                          onSelected: (_) => setState(() => _selectedAmount = amount),
                        ),
                      ChoiceChip(
                        label: const Text('Custom'),
                        selected: _selectedAmount == null,
                        onSelected: (_) => setState(() => _selectedAmount = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _donate,
                      icon: const Icon(Icons.favorite_outline),
                      label: Text(
                        _selectedAmount == null
                            ? 'Donate with Paynow'
                            : 'Donate \$${_selectedAmount!.toStringAsFixed(0)} via Paynow',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Opens Paynow in your browser. You can change the amount there.',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.gold, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.accentSoft(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.textSecondary(context)),
      ),
      trailing: Icon(Icons.open_in_new, color: AppColors.textMuted(context), size: 18),
      onTap: onTap,
    );
  }
}

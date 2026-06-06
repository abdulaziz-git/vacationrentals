import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/external_links.dart';

/// Account tab. Shows a signed-out hero with login/signup CTAs, then the
/// standard settings/help/owner-portal rows seen across the VRLBI footer.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.ocean,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to VRLBI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Log in to manage trips, saved homes, and quotes.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.ocean,
                        ),
                        onPressed: () => context.push('/login'),
                        child: const Text('Log in'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                        ),
                        onPressed: () => context.push('/signup'),
                        child: const Text('Sign up'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _group('Travelers', [
            _row(context, Icons.help_outline, 'How to Book'),
            _row(context, Icons.quiz_outlined, 'Traveler FAQs'),
            _row(context, Icons.verified_user_outlined, 'Scam-Free Guarantee'),
            _row(
              context,
              Icons.request_quote_outlined,
              'Get a Quote',
              onTap: () => context.go('/search'),
            ),
            _row(context, Icons.health_and_safety_outlined, 'Travel Insurance'),
          ]),
          const SizedBox(height: 16),
          _group('For Homeowners', [
            _row(context, Icons.add_home_outlined, 'List Your Property'),
            _row(
              context,
              Icons.workspace_premium_outlined,
              'Packages for Homeowners',
            ),
            _row(context, Icons.trending_up, 'Tips to Get More Inquiries'),
          ]),
          const SizedBox(height: 16),
          _group('Company', [
            _row(context, Icons.info_outline, 'About VRLBI'),
            _row(context, Icons.mail_outline, 'Contact Us'),
            _row(context, Icons.map_outlined, 'LBI Community Guides'),
            _row(context, Icons.settings_outlined, 'Settings'),
          ]),
          const SizedBox(height: 16),
          _group('Privacy & legal', [
            _row(
              context,
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              onTap: () => openExternal(context, ExternalLinks.privacyPolicy),
            ),
            _row(
              context,
              Icons.description_outlined,
              'Terms of Service',
              onTap: () => openExternal(context, ExternalLinks.terms),
            ),
            _row(
              context,
              Icons.logout,
              'Sign out',
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Signed out'))),
            ),
            _row(
              context,
              Icons.delete_outline,
              'Delete account',
              danger: true,
              onTap: () => _confirmDelete(context),
            ),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'VRLBI · Vacation Rentals Jersey Shore LLC\n'
              '518 Central Ave, Ship Bottom, NJ 08008',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'v1.0.0 (mockup build)',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.deepSea,
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.zero,
        child: Column(children: rows),
      ),
    ],
  );

  Widget _row(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final color = danger ? AppTheme.heart : AppTheme.ocean;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: danger ? AppTheme.heart : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      // Informational rows fall back to the VRLBI website until dedicated
      // in-app screens exist; specific rows override with their own action.
      onTap: onTap ?? () => openExternal(context, ExternalLinks.support),
    );
  }

  /// In-app account deletion path (App Store Guideline 5.1.1(v)).
  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your VRLBI account, saved homes, and trip '
          'history. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.heart),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your account has been deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

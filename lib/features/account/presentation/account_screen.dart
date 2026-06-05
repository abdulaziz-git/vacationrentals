import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Account tab. Shows a signed-out hero with login/signup CTAs, then the
/// standard settings/help/owner-portal rows seen across the VRLBI footer.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.ocean, Color(0xFF0A567A)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome to VRLBI',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Log in to manage trips, saved homes, and quotes.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.ocean),
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
            _row(Icons.help_outline, 'How to Book'),
            _row(Icons.quiz_outlined, 'Traveler FAQs'),
            _row(Icons.verified_user_outlined, 'Scam-Free Guarantee'),
            _row(Icons.request_quote_outlined, 'Get a Quote'),
            _row(Icons.health_and_safety_outlined, 'Travel Insurance'),
          ]),
          const SizedBox(height: 16),
          _group('For Homeowners', [
            _row(Icons.add_home_outlined, 'List Your Property'),
            _row(Icons.workspace_premium_outlined, 'Packages for Homeowners'),
            _row(Icons.trending_up, 'Tips to Get More Inquiries'),
          ]),
          const SizedBox(height: 16),
          _group('Company', [
            _row(Icons.info_outline, 'About VRLBI'),
            _row(Icons.mail_outline, 'Contact Us'),
            _row(Icons.map_outlined, 'LBI Community Guides'),
            _row(Icons.settings_outlined, 'Settings'),
          ]),
          const SizedBox(height: 24),
          Center(
            child: Text('VRLBI · Vacation Rentals Jersey Shore LLC\n'
                '518 Central Ave, Ship Bottom, NJ 08008',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text('v1.0.0 (mockup build)',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
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
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.deepSea)),
          ),
          Card(
            margin: EdgeInsets.zero,
            child: Column(children: rows),
          ),
        ],
      );

  Widget _row(IconData icon, String label) => ListTile(
        leading: Icon(icon, color: AppTheme.ocean),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {},
      );
}

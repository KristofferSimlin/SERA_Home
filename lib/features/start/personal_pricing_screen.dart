import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sera/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalPricingScreen extends StatelessWidget {
  const PersonalPricingScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kunde inte öppna länken')),
        );
      }
    }
  }

  Future<void> _openApp(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('personal_access', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.startLoginPersonal)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.personalPricingTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              l.personalPricingBody,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface.withOpacity(0.8),
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _openUrl(context,
                  'https://apps.apple.com/'), // TODO: replace with real link
              icon: const Icon(Icons.apple),
              label: Text(l.personalPricingStoreIos),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _openUrl(context,
                  'https://play.google.com/'), // TODO: replace with real link
              icon: const Icon(Icons.android),
              label: Text(l.personalPricingStoreAndroid),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _openApp(context),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l.personalPricingOpenApp),
            ),
          ],
        ),
      ),
    );
  }
}

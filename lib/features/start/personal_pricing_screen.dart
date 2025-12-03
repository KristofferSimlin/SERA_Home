import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sera/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/floating_lines_background.dart';

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
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    return Scaffold(
      appBar: AppBar(title: Text(l.startLoginPersonal)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B0D12), Color(0xFF0E141C)],
              ),
            ),
          ),
          if (isCurrentRoute)
            const Positioned.fill(
              child: FloatingLinesBackground(
                enabledWaves: ['middle'],
                lineCount: [6, 8],
                lineDistance: [10.0, 8.0],
                animationSpeed: 0.08,
                opacity: 0.6,
              ),
            ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                              color: cs.onSurface.withOpacity(0.85),
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.personalPricingTrial,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.9),
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary.withOpacity(0.9),
                          side: BorderSide(
                              color: cs.onPrimary.withOpacity(0.45), width: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        onPressed: () => _openUrl(
                          context,
                          'https://apps.apple.com/', // TODO: replace with real IAP link
                        ),
                        icon: const Icon(Icons.subscriptions),
                        label: Text(l.personalPricingSubscribe),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: cs.onSurface.withOpacity(0.5), width: 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        onPressed: () => _openApp(context),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(l.personalPricingOpenApp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

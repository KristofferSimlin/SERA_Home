import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.termsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.termsTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            l.termsBody.replaceAll('\\n', '\n'),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

class SubscriptionTermsScreen extends StatelessWidget {
  const SubscriptionTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.subscriptionTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.subscriptionTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            l.subscriptionBody.replaceAll('\\n', '\n'),
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

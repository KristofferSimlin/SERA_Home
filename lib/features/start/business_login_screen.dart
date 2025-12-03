import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

class BusinessLoginScreen extends StatelessWidget {
  const BusinessLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.startLoginBusiness)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.businessLoginTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              l.businessLoginBody,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface.withOpacity(0.8),
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // TODO: Replace with your actual business login route/SSO link.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.businessLoginButton)),
                );
              },
              icon: const Icon(Icons.login),
              label: Text(l.businessLoginButton),
            ),
          ],
        ),
      ),
    );
  }
}

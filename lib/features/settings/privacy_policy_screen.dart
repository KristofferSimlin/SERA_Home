import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.privacyTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.privacyTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            l.privacyFull,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            l.chatInfo,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}

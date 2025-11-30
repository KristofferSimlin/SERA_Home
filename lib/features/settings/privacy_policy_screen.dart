import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Normalisera så att både riktiga radbrytningar och literal "\n" blir radbrytningar.
    final normalized = l.privacyFull.replaceAll('\\n', '\n');
    final paragraphs = normalized.split('\n\n');
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
          ...paragraphs.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Paragraph(text: p),
            ),
          ),
          SelectableText(
            l.chatInfo,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // Om paragrafen innehåller punktlistor med "•", dela upp dem och rendera fint.
    if (text.contains('•')) {
      final lines = text.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            if (line.trim().isEmpty)
              const SizedBox(height: 4)
            else if (line.trim().startsWith('•'))
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: SelectableText(
                        line.trim().substring(1).trim(),
                        style: const TextStyle(height: 1.3),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SelectableText(
                  line.trim(),
                  style: const TextStyle(height: 1.3),
                ),
              ),
        ],
      );
    }

    return SelectableText(
      text.trim(),
      style: const TextStyle(height: 1.4),
    );
  }
}

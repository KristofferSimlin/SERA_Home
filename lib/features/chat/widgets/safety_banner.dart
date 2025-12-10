import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';

class SafetyBanner extends StatelessWidget {
  const SafetyBanner({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.safetyOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.safetyOrange.withOpacity(0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️ ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              l.chatSafetyBanner,
              style: const TextStyle(fontSize: 13.5, height: 1.35),
            ),
          ),
          if (onClose != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              tooltip: l.chatSafetyHide,
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

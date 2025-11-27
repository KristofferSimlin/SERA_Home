import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class SafetyBanner extends StatelessWidget {
  const SafetyBanner({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️ ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              'Säkerhetsfilter: Koppla från ström, avlasta tryck, ventilera vid bränslearbete. '
              'Använd skyddsutrustning. Följ alltid tillverkarens instruktioner.',
              style: TextStyle(fontSize: 13.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

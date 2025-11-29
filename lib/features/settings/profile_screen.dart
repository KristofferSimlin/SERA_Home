import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chats/chat_providers.dart' show sessionsProvider;
import '../chats/chat_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Profil & data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Rensa lokalt sparad data (sessioner, meddelanden, utrustning). '
                    'Krav från App Store: möjliggör radering av lagrad användardata.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Radera lagrad data'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Radera all lagrad data?'),
                          content: const Text(
                            'Detta raderar lokala sessioner, meddelanden och utrustningsval. Åtgärden går inte att ångra.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Avbryt'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Radera'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(chatRepoProvider).clearAllLocalData();
                        if (!context.mounted) return;
                        ref.invalidate(sessionsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All lokal data raderad')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Kommer snart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Här lägger vi till inloggning, snabbval av utrustning och andra profilinställningar.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

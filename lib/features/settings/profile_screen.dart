import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/l10n/app_localizations.dart';

import '../chats/chat_providers.dart' show sessionsProvider;
import '../chats/chat_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.profileTitle),
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
                  Text(l.profileDataTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    l.profileDataInfo,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: Text(l.profileDelete),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l.profileDeleteConfirmTitle),
                          content: Text(l.profileDeleteConfirmBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l.profileDeleteCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l.profileDeleteConfirm),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        try {
                          await ref.read(chatRepoProvider).clearAllLocalData();
                          if (!context.mounted) return;
                          ref.invalidate(sessionsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.profileDeleteDone)),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${l.error}: $e')),
                          );
                        }
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
                children: [
                  Text(l.profileComingSoonTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    l.profileComingSoonBody,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l.profilePrivacy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l.termsTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.subscriptions_outlined),
              title: Text(l.subscriptionTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/subscription-terms'),
            ),
          ),
        ],
      ),
    );
  }
}

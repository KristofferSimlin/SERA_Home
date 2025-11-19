import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_repository.dart';        // innehåller chatRepoProvider
import 'chat_models.dart';
import 'chat_providers.dart';
import '../chat/chat_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _search = TextEditingController();

  Future<void> _refresh() async {
    ref.invalidate(sessionsProvider);
    await ref.read(sessionsProvider.future);
  }

  Future<void> _newChat() async {
    final id = await ref.read(chatRepoProvider).createSession();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: id)),
    );
    if (mounted) _refresh();
  }

  Future<void> _onSearch(String q) async {
    final list = await ref.read(chatRepoProvider).search(q);
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Sökresultat'),
        children: list.isEmpty
            ? [const Padding(padding: EdgeInsets.all(16), child: Text('Inga träffar'))]
            : list
                .map((s) => SimpleDialogOption(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id)),
                        ).then((_) => _refresh());
                      },
                      child: Text(s.title),
                    ))
                .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SERA — Chattar'),
        actions: [
          IconButton(
            tooltip: 'Ny chatt',
            onPressed: _newChat,
            icon: const Icon(Icons.add_comment),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Sök chattar…',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _onSearch(_search.text),
                  child: const Text('Sök'),
                ),
              ],
            ),
          ),
          Expanded(
            child: sessions.when(
              data: (list) => list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Inga chattar än.'),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _newChat,
                              icon: const Icon(Icons.add),
                              label: const Text('Ny chatt'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, i) {
                        final s = list[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Uppdaterad: ${s.updatedAt}'),
                          leading: const Icon(Icons.chat_bubble_outline),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Byt namn',
                                icon: const Icon(Icons.drive_file_rename_outline),
                                onPressed: () => _renameSession(s),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await ref.read(chatRepoProvider).deleteSession(s.id);
                                  if (mounted) _refresh();
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id)),
                            ).then((_) => _refresh());
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: list.length,
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fel: $e')),
            ),
          ),
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Tips: Skapa ny chatt eller sök bland äldre.',
                style: TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newChat,
        icon: const Icon(Icons.add),
        label: const Text('Ny chatt'),
      ),
    );
  }

  Future<void> _renameSession(ChatSessionMeta session) async {
    final controller = TextEditingController(text: session.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Döp om chatt'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 48,
          decoration: const InputDecoration(hintText: 'Ange nytt namn'),
          onSubmitted: (value) => Navigator.of(ctx).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Avbryt'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Spara'),
          ),
        ],
      ),
    );
    final trimmed = newTitle?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    await ref.read(chatRepoProvider).renameSession(session.id, trimmed);
    if (mounted) _refresh();
  }
}

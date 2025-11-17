import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../chats/chat_list_screen.dart' show sessionsProvider;
import '../chats/chat_repository.dart';
import '../chat/chat_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  final _search = TextEditingController();

  Future<void> _newChat() async {
    final id = await ref.read(chatRepoProvider).createSession();
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(sessionId: id)));
  }

  void _openChat(String id) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(sessionId: id)));
  }

  @override
  Widget build(BuildContext context) {
    // Responsiv layout: bred skärm -> fast sidofält, smal -> Drawer
    final isWide = MediaQuery.of(context).size.width >= 900;
    final sidebar = _Sidebar(
      onNewChat: _newChat,
      onOpenChat: _openChat,
      searchCtrl: _search,
    );

    return Scaffold(
      drawer: isWide ? null : Drawer(child: SafeArea(child: sidebar)),
      appBar: isWide
          ? null
          : AppBar(
              title: const Text('SERA'),
              actions: [
                IconButton(
                  tooltip: 'Ny chatt',
                  onPressed: _newChat,
                  icon: const Icon(Icons.add_comment),
                ),
                IconButton(
                  tooltip: 'Inställningar',
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
      body: Row(
        children: [
          if (isWide) SizedBox(width: 320, child: Material(color: Theme.of(context).colorScheme.surface, child: SafeArea(child: sidebar))),
          Expanded(child: _LandingArea(onNewChat: _newChat)),
        ],
      ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton.extended(
              onPressed: _newChat,
              icon: const Icon(Icons.add),
              label: const Text('Ny chatt'),
            ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.onNewChat,
    required this.onOpenChat,
    required this.searchCtrl,
  });

  final VoidCallback onNewChat;
  final void Function(String id) onOpenChat;
  final TextEditingController searchCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Topp: Ny chatt + Sök
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add),
                  label: const Text('Ny chatt'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Inställningar',
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                icon: const Icon(Icons.settings),
              )
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: const InputDecoration(
              hintText: 'Sök i chattar…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Lista: tidigare chattar
          Expanded(
            child: sessions.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Inga chattar ännu'),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final s = list[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${s.updatedAt}'),
                      onTap: () => onOpenChat(s.id),
                      trailing: IconButton(
                        tooltip: 'Radera',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref.read(chatRepoProvider).deleteSession(s.id);
                          ref.invalidate(sessionsProvider);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fel: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingArea extends StatelessWidget {
  const _LandingArea({required this.onNewChat});
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.surface.withOpacity(0.0),
            cs.surface.withOpacity(0.25),
          ],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stor rubrik
                Text(
                  'Välkommen till SERA',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Service & Equipment Repair Assistant',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 24),

                // Förslag ("prompt suggestions")
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _SuggestionChip('Felsökning – motor startar inte'),
                    _SuggestionChip('Läs felkod & nästa steg'),
                    _SuggestionChip('Underhåll – checklista'),
                    _SuggestionChip('Säkerhetsråd – hydraulik'),
                  ],
                ),
                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add_comment),
                  label: const Text('Starta ny chatt'),
                ),

                const SizedBox(height: 32),
                const _Disclaimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(text),
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tips valt: $text — tryck Ny chatt och klistra in')),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Informationen är vägledande. Följ alltid tillverkarens instruktioner och lokala säkerhetsregler. Egen risk.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.35),
    );
  }
}

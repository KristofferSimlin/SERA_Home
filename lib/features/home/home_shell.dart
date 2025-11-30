import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/l10n/app_localizations.dart';
import '../chats/chat_models.dart';
import '../chats/chat_providers.dart' show sessionsProvider;
import '../chats/chat_repository.dart';
import '../chat/chat_screen.dart';
import '../start/widgets/floating_lines_background.dart';

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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: id)),
    );
    if (mounted) {
      ref.invalidate(sessionsProvider);
    }
  }

  Future<void> _openChat(String id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: id)),
    );
    if (mounted) {
      ref.invalidate(sessionsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsiv layout: bred skärm -> fast sidofält, smal -> Drawer
    final isWide = MediaQuery.of(context).size.width >= 900;
    final showAppBar = !isWide || kIsWeb;
    final l = AppLocalizations.of(context)!;
    final sidebar = _Sidebar(
      onNewChat: () {
        _newChat();
      },
      onOpenChat: (id) {
        _openChat(id);
      },
      searchCtrl: _search,
      showNavLinks: !isWide,
    );

    return Scaffold(
      drawer: isWide ? null : Drawer(child: SafeArea(child: sidebar)),
      appBar: showAppBar
          ? AppBar(
              automaticallyImplyLeading: !isWide,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.homeAppBarTitle),
                  if (isWide) ...[
                    const SizedBox(width: 16),
                    IconButton(
                      tooltip: l.homeAcademy,
                      onPressed: () {},
                      icon: const Icon(Icons.school),
                    ),
                    IconButton(
                      tooltip: l.homeForum,
                      onPressed: () {},
                      icon: const Icon(Icons.forum),
                    ),
                  ],
                ],
              ),
              actions: [
                IconButton(
                  tooltip: l.homeProfile,
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const Icon(Icons.person),
                ),
                IconButton(
                  tooltip: l.homeNewChat,
                  onPressed: () {
                    _newChat();
                  },
                  icon: const Icon(Icons.add_comment),
                ),
                IconButton(
                  tooltip: l.homeSettings,
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  icon: const Icon(Icons.settings),
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isWide)
            SizedBox(
                width: 320,
                child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: SafeArea(child: sidebar))),
          Expanded(
            child: _LandingArea(
              onNewChat: () {
                _newChat();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.onNewChat,
    required this.onOpenChat,
    required this.searchCtrl,
    required this.showNavLinks,
  });

  final VoidCallback onNewChat;
  final void Function(String id) onOpenChat;
  final TextEditingController searchCtrl;
  final bool showNavLinks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(sessionsProvider);
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (showNavLinks) ...[
            Row(
              children: [
                _NavButton(
                    label: l.homeAcademy,
                    subtitle: l.comingSoon,
                    icon: Icons.school),
                const SizedBox(width: 8),
                _NavButton(
                    label: l.homeForum,
                    subtitle: l.comingSoon,
                    icon: Icons.forum),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Topp: Ny chatt + Sök
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onNewChat,
                  icon: const Icon(Icons.add),
                  label: Text(l.homeNewChat),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: l.homeSettings,
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
            decoration: InputDecoration(
              hintText: l.homeSearchHint,
              prefixIcon: const Icon(Icons.search),
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
                  return Center(
                    child: Text(l.homeNoChats),
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
                      title: Text(s.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${s.updatedAt}'),
                      onTap: () => onOpenChat(s.id),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: l.homeRename,
                            icon: const Icon(Icons.drive_file_rename_outline),
                            onPressed: () => _renameSession(context, ref, s),
                          ),
                          IconButton(
                            tooltip: l.homeDelete,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await ref
                                  .read(chatRepoProvider)
                                  .deleteSession(s.id);
                              ref.invalidate(sessionsProvider);
                            },
                          ),
                        ],
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

  Future<void> _renameSession(
    BuildContext context,
    WidgetRef ref,
    ChatSessionMeta session,
  ) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: session.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.homeRenameDialogTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 48,
          decoration: InputDecoration(hintText: l.homeRenameDialogHint),
          onSubmitted: (value) => Navigator.of(ctx).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.homeRenameCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(l.homeRenameSave),
          ),
        ],
      ),
    );
    final trimmed = newTitle?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    await ref.read(chatRepoProvider).renameSession(session.id, trimmed);
    ref.invalidate(sessionsProvider);
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String label;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label — $subtitle')),
          );
        },
        icon: Icon(icon, size: 20, color: color),
        label: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ],
        ),
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
    const isWeb = kIsWeb;
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    return TickerMode(
      enabled: isCurrentRoute,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.surface.withOpacity(0.65),
                  cs.surface.withOpacity(0.85),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: FloatingLinesBackground(
              enabledWaves: const ['top', 'middle', 'bottom'],
              // Färre linjer och långsammare animering på web för bättre prestanda
              lineCount: isWeb ? const [4, 6, 8] : const [8, 12, 16],
              lineDistance:
                  isWeb ? const [10.0, 8.0, 6.0] : const [7.0, 5.0, 4.0],
              animationSpeed: isWeb ? 0.08 : 0.16,
              opacity: isWeb ? 0.55 : 0.8,
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stor rubrik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SERA',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'BETA',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Service & Equipment Repair Assistant',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 24),

                    // Förslag ("prompt suggestions")
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
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
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(text),
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Tips valt: $text — tryck Ny chatt och klistra in')),
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

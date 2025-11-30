import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
    final l = AppLocalizations.of(context)!;
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
                      l.startSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    const _FeatureCards(),
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

class _FeatureCards extends StatelessWidget {
  const _FeatureCards();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _CardData(
        title: 'Felsökning',
        badge: 'FELSÖKNING',
        description:
            'SERA hjälper dig att snabbt identifiera fel i entreprenadmaskiner med AI-drivna analyser.\n'
            'Förklara symtom, få förslag på orsaker och steg-för-steg-lösningar.\n'
            'Perfekt för både fälttekniker och mekaniker som behöver snabba svar.\n'
            'Alltid tillgängligt och uppdaterat.',
      ),
      _CardData(
        title: 'Underhåll',
        badge: 'UNDERHÅLL',
        description:
            'Få tydliga instruktioner för service, inspektion och planerat underhåll.\n'
            'SERA guidar dig genom rätt intervaller, rekommenderade åtgärder och vanliga problem.\n'
            'Mindre gissande, mer struktur.\n'
            'Hjälper dig hålla maskinerna driftsäkra längre.',
      ),
      _CardData(
        title: 'Utbildning',
        badge: 'UTBILDNING',
        description:
            'SERA Academy erbjuder guider, utbildningar och lättförståeligt material.\n'
            'Lär dig funktioner, system, installationer och säkerhetsrutiner.\n'
            'Perfekt för nya tekniker eller den som vill utveckla sina färdigheter.\n'
            'Allt samlat i ett enkelt, digitalt format.',
      ),
      _CardData(
        title: 'Community',
        badge: 'COMMUNITY',
        description:
            'Ett forum där tekniker, förare och entusiaster kan dela kunskap och erfarenheter.\n'
            'Ställ frågor, diskutera lösningar och hjälp andra i branschen.\n'
            'Bygger en stark gemenskap runt SERA och entreprenadmaskiner.\n'
            'En plats att lära, inspireras och växa tillsammans.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const spacing = 12.0;
        final columns = width >= 880
            ? 4
            : width >= 640
                ? 2
                : 1;
        final itemWidth =
            columns == 1 ? width : (width - spacing * (columns - 1)) / columns;

        return Align(
          alignment: Alignment.center,
          child: Wrap(
            spacing: spacing,
            runSpacing: 16,
            children: cards
                .map((card) => SizedBox(
                      width: itemWidth,
                      child: _HoverCard(data: card),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.data});

  final _CardData data;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _expanded = false;

  void _setHover(bool value) {
    if (_expanded == value) return;
    setState(() {
      _expanded = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = Colors.white
        .withOpacity(_expanded ? 0.12 : 0.08); // subtle glow on hover

    return MouseRegion(
      onEnter: (e) {
        if (e.kind == PointerDeviceKind.mouse) {
          _setHover(true);
        }
      },
      onExit: (e) {
        if (e.kind == PointerDeviceKind.mouse) {
          _setHover(false);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _setHover(!_expanded), // tap support on touch devices
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(_expanded ? 18 : 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(_expanded ? 0.28 : 0.16),
            ),
            boxShadow: _expanded
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Center(
                  child: Text(
                    widget.data.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 0, end: _expanded ? 1 : 0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.badge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.data.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.48,
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (context, value, child) {
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      heightFactor: value,
                      child: Opacity(opacity: value, child: child),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  const _CardData({
    required this.title,
    required this.badge,
    required this.description,
  });

  final String title;
  final String badge;
  final String description;
}

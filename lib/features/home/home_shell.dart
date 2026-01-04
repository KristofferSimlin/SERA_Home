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
import '../start/widgets/floating_lines_light_background.dart';
import '../../services/supabase_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/auth_params.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  final _search = TextEditingController();
  bool _showAdminOnboarding = false;

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

  Future<void> _openWorkOrder() async {
    await Navigator.pushNamed(context, '/work-order');
  }

  Future<void> _openGeneralChat() async {
    final id = await ref.read(chatRepoProvider).createSession();
    if (!mounted) return;
    await Navigator.pushNamed(context, '/general-chat', arguments: id);
    if (mounted) {
      ref.invalidate(sessionsProvider);
    }
  }

  Future<void> _openService() async {
    await Navigator.pushNamed(context, '/service');
  }

  @override
  void initState() {
    super.initState();
    _initOnboarding();
  }

  Future<void> _initOnboarding() async {
    final role = supabase.auth.currentUser?.appMetadata['role']?.toString();
    // Visa alltid för admin under felsökning
    if (role == 'admin') setState(() => _showAdminOnboarding = true);
  }

  Future<void> _dismissOnboarding() async {
    if (mounted) {
      setState(() {
        _showAdminOnboarding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsiv layout: bred skärm -> fast sidofält, smal -> Drawer
    final isWide = MediaQuery.of(context).size.width >= 900;
    final showAppBar = !isWide || kIsWeb;
    final l = AppLocalizations.of(context)!;
    final sidebar = _Sidebar(
      onLogout: () async {
        await supabase.auth.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      },
      currentUserEmail: supabase.auth.currentUser?.email,
      currentUserRole:
          supabase.auth.currentUser?.appMetadata['role']?.toString(),
      onNewChat: () {
        _newChat();
      },
      onOpenChat: (id) {
        _openChat(id);
      },
      searchCtrl: _search,
      showNavLinks: !isWide,
    );

    final bodyContent = Row(
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
            onService: () {
              _openService();
            },
            onWorkOrder: () {
              _openWorkOrder();
            },
          ),
        ),
      ],
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
                if (supabase.auth.currentUser?.appMetadata['role'] == 'admin')
                  IconButton(
                    tooltip: 'Adminpanel',
                    onPressed: () => Navigator.pushNamed(context, '/admin'),
                    icon: const Icon(Icons.admin_panel_settings),
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
          body: Stack(
            children: [
              bodyContent,
              if (_showAdminOnboarding)
                Positioned(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight - 10,
                  right: 72,
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.arrow_drop_up, color: Colors.grey, size: 32),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2228),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black.withOpacity(0.4)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 6),
                              const Text(
                                'Adminpanelen: lägg till användare/licenser',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                '1/1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _dismissOnboarding,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Next'),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _dismissOnboarding,
                                child: const Icon(Icons.close, size: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      bottomNavigationBar: _MobileBottomBar(
        onService: _openService,
        onFelsokning: _newChat,
        onWorkOrder: _openWorkOrder,
        onProfile: () => Navigator.pushNamed(context, '/profile'),
        onChat: _openGeneralChat,
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.onLogout,
    required this.currentUserEmail,
    required this.currentUserRole,
    required this.onNewChat,
    required this.onOpenChat,
    required this.searchCtrl,
    required this.showNavLinks,
  });

  final Future<void> Function() onLogout;
  final String? currentUserEmail;
  final String? currentUserRole;
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
          if (currentUserEmail != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                currentUserEmail!,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            if ((currentUserRole ?? '').isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
              child: Text(
                'Roll: ${currentUserRole!}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logga ut'),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
          ],
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
  const _LandingArea({
    required this.onNewChat,
    required this.onService,
    required this.onWorkOrder,
  });
  final VoidCallback onNewChat;
  final VoidCallback onService;
  final VoidCallback onWorkOrder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTextColor = isDark ? Colors.white : Colors.black87;
    final mutedTextColor = isDark ? Colors.white70 : Colors.black54;
    final badgeBg = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);
    const isWeb = kIsWeb;
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    final lineCount = isWeb ? const [4, 6, 8] : const [8, 12, 16];
    final lineDistance = isWeb ? const [10.0, 8.0, 6.0] : const [7.0, 5.0, 4.0];
    final backgroundLayers = isDark
        ? <Widget>[
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
                lineCount: lineCount,
                lineDistance: lineDistance,
                animationSpeed: isWeb ? 0.08 : 0.16,
                opacity: isWeb ? 0.55 : 0.8,
              ),
            ),
          ]
        : <Widget>[
            FloatingLinesLightBackground(
              enabledWaves: const ['top', 'middle', 'bottom'],
              lineCount: lineCount,
              lineDistance: lineDistance,
              animationSpeed: isWeb ? 0.08 : 0.16,
              opacity: isWeb ? 0.55 : 0.8,
            ),
          ];
    return TickerMode(
      enabled: isCurrentRoute,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ...backgroundLayers,
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
                        Image.asset(
                          'sera_logo/SERA6.png',
                          height: 70,
                          semanticLabel: 'SERA logo',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SERA',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: baseTextColor,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: badgeBg,
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
                                  color: baseTextColor,
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
                          ?.copyWith(color: mutedTextColor),
                    ),
                    const SizedBox(height: 20),
                    _FeatureCards(
                      onTroubleshootingTap: onNewChat,
                      onMaintenanceTap: onService,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),
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

class _FeatureCards extends StatefulWidget {
  const _FeatureCards({
    required this.onTroubleshootingTap,
    required this.onMaintenanceTap,
    required this.isDark,
  });

  final VoidCallback onTroubleshootingTap;
  final VoidCallback onMaintenanceTap;
  final bool isDark;

  @override
  State<_FeatureCards> createState() => _FeatureCardsState();
}

class _FeatureCardsState extends State<_FeatureCards> {
  int? _mobileExpanded;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final cards = [
      _CardData(
        title: l.homeCardTroubleshootingTitle,
        badge: l.homeCardTroubleshootingBadge,
        description: l.homeCardTroubleshootingBody,
        onTap: widget.onTroubleshootingTap,
      ),
      _CardData(
        title: l.homeCardMaintenanceTitle,
        badge: l.homeCardMaintenanceBadge,
        description: l.homeCardMaintenanceBody,
        onTap: widget.onMaintenanceTap,
      ),
      _CardData(
        title: l.homeCardTrainingTitle,
        badge: l.homeCardTrainingBadge,
        description: l.homeCardTrainingBody,
      ),
      _CardData(
        title: l.homeCardCommunityTitle,
        badge: l.homeCardCommunityBadge,
        description: l.homeCardCommunityBody,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const spacing = 10.0;
        final isMobile = width < 720;
        final textColor = widget.isDark ? Colors.white : Colors.black87;
        final mutedTextColor = widget.isDark ? Colors.white70 : Colors.black54;
        final borderBaseColor = widget.isDark ? Colors.white : Colors.black87;
        // Försök hålla 2 kolumner även på mobil; fall back till 1 först vid riktigt smal viewport
        final columns = viewportWidth >= 880
            ? 4
            : viewportWidth >= 320
                ? 2
                : 1;
        final itemWidth =
            columns == 1 ? width : (width - spacing * (columns - 1)) / columns;
        final compactText = width < 420;

        return Align(
          alignment: Alignment.center,
          child: Wrap(
            spacing: spacing,
            runSpacing: 16,
            children: [
              for (var i = 0; i < cards.length; i++)
                Builder(builder: (context) {
                  final card = cards[i];
                  final onTap = isMobile
                      ? () {
                          setState(() {
                            _mobileExpanded = _mobileExpanded == i ? null : i;
                          });
                        }
                      : card.onTap;
                  final expandedOverride = isMobile ? _mobileExpanded == i : null;

                  return SizedBox(
                    width: itemWidth,
                    child: _HoverCard(
                      data: card,
                      compactText: compactText,
                      expandedOverride: expandedOverride,
                      onTap: onTap,
                      textColor: textColor,
                      mutedTextColor: mutedTextColor,
                      borderBaseColor: borderBaseColor,
                      showActionButton: isMobile,
                      action: card.onTap,
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _HoverCard extends StatefulWidget {
  const _HoverCard({
    required this.data,
    required this.compactText,
    this.expandedOverride,
    this.onTap,
    required this.textColor,
    required this.mutedTextColor,
    required this.borderBaseColor,
    required this.showActionButton,
    this.action,
  });

  final _CardData data;
  final bool compactText;
  final bool? expandedOverride;
  final VoidCallback? onTap;
  final Color textColor;
  final Color mutedTextColor;
  final Color borderBaseColor;
  final bool showActionButton;
  final VoidCallback? action;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard>
    with SingleTickerProviderStateMixin {
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
    final expanded = widget.expandedOverride ?? _expanded;
    final baseColor = widget.borderBaseColor;
    final bgColor = baseColor.withOpacity(expanded ? 0.12 : 0.08);
    final borderColor = baseColor.withOpacity(expanded ? 0.28 : 0.16);

    return MouseRegion(
      onEnter: (e) {
        if (e.kind == PointerDeviceKind.mouse &&
            widget.expandedOverride == null) {
          _setHover(true);
        }
      },
      onExit: (e) {
        if (e.kind == PointerDeviceKind.mouse &&
            widget.expandedOverride == null) {
          _setHover(false);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            _setHover(!expanded); // tap support on touch devices
          }
        },
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
              boxShadow: expanded
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Center(
                    child: Text(
                      widget.data.title,
                      textAlign: TextAlign.center,
                      style: (widget.compactText
                              ? theme.textTheme.titleSmall
                              : theme.textTheme.titleMedium)
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                      ),
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: expanded ? 1 : 0),
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
                            color: widget.mutedTextColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.data.description,
                          style: (widget.compactText
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            color: widget.mutedTextColor,
                            height: 1.48,
                          ),
                        ),
                        if (widget.showActionButton && widget.action != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: FilledButton.icon(
                              onPressed: widget.action,
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(widget.data.title),
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
      ),
    );
  }
}

class _CardData {
  const _CardData({
    required this.title,
    required this.badge,
    required this.description,
    this.onTap,
  });

  final String title;
  final String badge;
  final String description;
  final VoidCallback? onTap;
}

class _MobileBottomBar extends StatelessWidget {
  const _MobileBottomBar({
    required this.onService,
    required this.onFelsokning,
    required this.onWorkOrder,
    required this.onProfile,
    required this.onChat,
  });

  final VoidCallback onService;
  final VoidCallback onFelsokning;
  final VoidCallback onWorkOrder;
  final VoidCallback onProfile;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white70,
          fontSize: 11,
        );

    return SafeArea(
      top: false,
      child: Material(
        color: const Color(0xFF0F141A),
        elevation: 8,
        child: SizedBox(
          height: 86,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: _BottomItem(
                        icon: Icons.build_circle_outlined,
                        label: l.serviceCta,
                        onTap: onService,
                        labelStyle: labelStyle,
                      ),
                    ),
                    Expanded(
                      child: _BottomItem(
                        icon: Icons.troubleshoot_outlined,
                        label: l.homeNewChat,
                        onTap: onFelsokning,
                        labelStyle: labelStyle,
                      ),
                    ),
                    const SizedBox(width: 76), // space for center fab
                    Expanded(
                      child: _BottomItem(
                        icon: Icons.assignment_turned_in_outlined,
                        label: l.workOrderCta,
                        onTap: onWorkOrder,
                        labelStyle: labelStyle,
                      ),
                    ),
                    Expanded(
                      child: _BottomItem(
                        icon: Icons.person_outline,
                        label: l.homeProfile,
                        onTap: onProfile,
                        labelStyle: labelStyle,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                child: SizedBox(
                  width: 66,
                  height: 66,
                  child: FloatingActionButton(
                    onPressed: onChat,
                    backgroundColor: cs.primary,
                    child: const Icon(Icons.chat_bubble_outline, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.labelStyle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white70),
            const SizedBox(height: 4),
            Text(label, style: labelStyle, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// lib/features/chat/chat_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/l10n/app_localizations.dart';

import 'chat_controller.dart'; // <-- vanlig import, ingen show-filter
import '../chats/chat_providers.dart' show sessionsProvider;
import '../chats/chat_repository.dart';
import 'widgets/chat_backdrop.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/safety_banner.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.sessionId});
  final String sessionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;

  final _brandFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _yearFocus = FocusNode();

  bool _lock = false;
  bool _equipmentCollapsed = false;
  bool _showSafetyBanner = true;

  // Litet hjälp-API för att få en korrekt typad notifier
  ChatController _ctrl() => ref.read(chatControllerProvider(widget.sessionId).notifier);

  @override
  void initState() {
    super.initState();

    final st = ref.read(chatControllerProvider(widget.sessionId));
    _brandCtrl = TextEditingController(text: st.brand ?? '');
    _modelCtrl = TextEditingController(text: st.model ?? '');
    _yearCtrl  = TextEditingController(text: st.year ?? '');
    _lock = st.equipmentLocked;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ctrl().suppressEquipmentQuestion();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _brandFocus.dispose();
    _modelFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _applyEquipment({bool silent = false, bool collapse = false}) {
    _ctrl().updateEquipment(
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
      year:  _yearCtrl.text.trim().isEmpty  ? null : _yearCtrl.text.trim(),
      lock: _lock,
    );
    if (collapse && _equipmentCollapsed == false) {
      setState(() {
        _equipmentCollapsed = true;
      });
    }
    if (!silent) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Utrustning uppdaterad')));
    }
  }

  void _clearEquipment() {
    setState(() {
      _brandCtrl.clear();
      _modelCtrl.clear();
      _yearCtrl.clear();
      _lock = false;
    });
    _ctrl().updateEquipment(brand: null, model: null, year: null, lock: false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Utrustning rensad')));
  }

  Future<void> _promptRenameSession() async {
    final repo = ref.read(chatRepoProvider);
    final current = await repo.getSession(widget.sessionId);
    if (!mounted) return;
    final controller = TextEditingController(text: current?.title ?? '');
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Döp om chatt'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 48,
          decoration: const InputDecoration(hintText: 'Ange nytt chattnamn'),
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
    if (!mounted) return;
    final trimmed = newTitle?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    await repo.renameSession(widget.sessionId, trimmed);
    if (!mounted) return;
    ref.invalidate(sessionsProvider);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Chatt döpt om till "$trimmed"')));
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await _ctrl().send(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.sessionId));
    final l = AppLocalizations.of(context)!;

    ref.listen<ChatState>(
      chatControllerProvider(widget.sessionId),
      (prev, next) {
        final prevMessages = prev?.messages ?? const [];
        final nextMessages = next.messages;
        final lengthChanged = prevMessages.length != nextMessages.length;
        final lastUpdated = !lengthChanged &&
            nextMessages.isNotEmpty &&
            prevMessages.isNotEmpty &&
            nextMessages.last.text != prevMessages.last.text;
        if (lengthChanged || lastUpdated) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(animated: lengthChanged),
          );
        }
      },
    );

    // Synka fält ↔ state (skriv inte över när fältet är fokuserat)
    if (!_brandFocus.hasFocus && _brandCtrl.text != (state.brand ?? '')) {
      _brandCtrl.text = state.brand ?? '';
      _brandCtrl.selection = TextSelection.collapsed(offset: _brandCtrl.text.length);
    }
    if (!_modelFocus.hasFocus && _modelCtrl.text != (state.model ?? '')) {
      _modelCtrl.text = state.model ?? '';
      _modelCtrl.selection = TextSelection.collapsed(offset: _modelCtrl.text.length);
    }
    if (!_yearFocus.hasFocus && _yearCtrl.text != (state.year ?? '')) {
      _yearCtrl.text = state.year ?? '';
      _yearCtrl.selection = TextSelection.collapsed(offset: _yearCtrl.text.length);
    }
    if (_lock != state.equipmentLocked) _lock = state.equipmentLocked;

    final cs = Theme.of(context).colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 720;
    final isWebMobile = kIsWeb && isCompact;
    final equipmentSummary = [
      state.brand?.trim(),
      state.model?.trim(),
      state.year?.trim(),
    ].where((e) => e != null && e!.isNotEmpty).map((e) => e!).join(' • ');
    final hasEquipmentSummary = equipmentSummary.isNotEmpty;
    final equipmentSummaryText = hasEquipmentSummary ? equipmentSummary : 'Inget valt';
    final chat = _ctrl(); // typad notifier för enklare anrop nedan
    final equipmentForm = Column(
      children: [
        if (isCompact) ...[
          TextField(
            focusNode: _brandFocus,
            controller: _brandCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.chatBrandLabel,
              hintText: l.chatBrandHint,
            ),
            onChanged: (_) => _applyEquipment(silent: true),
          ),
          const SizedBox(height: 10),
          TextField(
            focusNode: _modelFocus,
            controller: _modelCtrl,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.chatModelLabel,
              hintText: l.chatModelHint,
            ),
            onChanged: (_) => _applyEquipment(silent: true),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: TextField(
                  focusNode: _yearFocus,
                  controller: _yearCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l.chatYearLabel,
                    hintText: l.chatYearHint,
                  ),
                  onChanged: (_) => _applyEquipment(silent: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: state.expertise,
                  decoration: InputDecoration(
                    labelText: l.chatExpertiseLabel,
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text(l.chatExpertise1)),
                    DropdownMenuItem(value: 2, child: Text(l.chatExpertise2)),
                    DropdownMenuItem(value: 3, child: Text(l.chatExpertise3)),
                  ],
                  onChanged: (val) {
                    chat.setExpertise(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val == 1
                              ? 'Nivå satt till Nybörjare'
                              : val == 2
                                  ? 'Nivå satt till Medel'
                                  : val == 3
                                      ? 'Nivå satt till Expert'
                                      : 'Nivå rensad',
                        ),
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: _brandFocus,
                  controller: _brandCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l.chatBrandLabel,
                    hintText: l.chatBrandHint,
                  ),
                  onChanged: (_) => _applyEquipment(silent: true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  focusNode: _modelFocus,
                  controller: _modelCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l.chatModelLabel,
                    hintText: l.chatModelHint,
                  ),
                  onChanged: (_) => _applyEquipment(silent: true),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: TextField(
                  focusNode: _yearFocus,
                  controller: _yearCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l.chatYearLabel,
                    hintText: l.chatYearHint,
                  ),
                  onChanged: (_) => _applyEquipment(silent: true),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<int>(
                  value: state.expertise,
                  decoration: InputDecoration(
                    labelText: l.chatExpertiseLabel,
                  ),
                  items: [
                    DropdownMenuItem(value: 1, child: Text(l.chatExpertise1)),
                    DropdownMenuItem(value: 2, child: Text(l.chatExpertise2)),
                    DropdownMenuItem(value: 3, child: Text(l.chatExpertise3)),
                  ],
                  onChanged: (val) {
                    chat.setExpertise(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val == 1
                              ? 'Nivå satt till Nybörjare'
                              : val == 2
                                  ? 'Nivå satt till Medel'
                                  : val == 3
                                      ? 'Nivå satt till Expert'
                                      : 'Nivå rensad',
                        ),
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        if (isCompact) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: cs.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _statusText(state, l),
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _clearEquipment,
                icon: const Icon(Icons.restart_alt, size: 18),
                label: Text(l.chatClear),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _lock,
                    onChanged: (v) {
                      setState(() => _lock = v);
                      chat.setEquipmentLocked(v);
                    },
                  ),
                  const Text('Lås'),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _applyEquipment(collapse: isWebMobile),
                icon: const Icon(Icons.save),
                label: Text(l.chatSave),
              ),
            ],
          ),
        ] else ...[
          Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: cs.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _statusText(state, l),
                      style: const TextStyle(fontSize: 12.5),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            TextButton.icon(
              onPressed: _clearEquipment,
              icon: const Icon(Icons.restart_alt, size: 18),
              label: Text(l.chatClear),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _lock,
              onChanged: (v) {
                setState(() => _lock = v);
                chat.setEquipmentLocked(v);
              },
            ),
            Text(l.chatLock),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _applyEquipment(collapse: isWebMobile),
              icon: const Icon(Icons.save),
              label: Text(l.chatSave),
            ),
            ],
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'debug → brand:${state.brand ?? "-"} | model:${state.model ?? "-"} | year:${state.year ?? "-"} | level:${state.expertise ?? "-"} | locked:${state.equipmentLocked}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.chatAppBarTitle),
        actions: [
          IconButton(
            tooltip: 'Döp om chatt',
            onPressed: _promptRenameSession,
            icon: const Icon(Icons.drive_file_rename_outline),
          ),
          IconButton(
            tooltip: _lock ? 'Lås av utrustning' : 'Lås utrustning',
            onPressed: () {
              setState(() => _lock = !_lock);
              chat.setEquipmentLocked(_lock);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_lock ? 'Utrustning låst' : 'Utrustning olåst')),
              );
            },
            icon: Icon(_lock ? Icons.lock_outline : Icons.lock_open),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: ChatBackdrop(
              speed: 1.5,
              intensity: 1.6,
            ),
          ),
          Column(
            children: [
          // Utrustning + nivå + status
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isWebMobile)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _equipmentCollapsed ? equipmentSummaryText : 'Utrustning',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _equipmentCollapsed ? Colors.white70 : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _equipmentCollapsed = !_equipmentCollapsed);
                            },
                            icon: Icon(_equipmentCollapsed ? Icons.unfold_more : Icons.unfold_less),
                            label: Text(_equipmentCollapsed ? 'Ändra' : 'Göm'),
                          ),
                        ],
                      ),
                    if (isWebMobile) const SizedBox(height: 8),
                    if (isWebMobile)
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: equipmentForm,
                        crossFadeState:
                            _equipmentCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 220),
                        sizeCurve: Curves.easeInOut,
                      )
                    else
                      equipmentForm,
                  ],
                ),
              ),
            ),
          ),

          if (state.hasSafetyRisk && _showSafetyBanner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SafetyBanner(
                onClose: () => setState(() => _showSafetyBanner = false),
              ),
            )
          else if (state.hasSafetyRisk && !_showSafetyBanner)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showSafetyBanner = true),
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: Text(l.chatSafetyShow),
                ),
              ),
            ),

          const SizedBox(height: 6),

          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: state.messages.length,
              itemBuilder: (_, i) {
                final m = state.messages[i];
                return ChatBubble(
                  isUser: m.role == ChatRole.user,
                  text: m.text,
                  time: m.time,
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l.chatInfo,
                style: const TextStyle(color: Color.fromARGB(179, 241, 238, 238), fontSize: 12.5),
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                    controller: _input,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: l.chatInputHint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: state.isSending ? null : _send,
                  icon: const Icon(Icons.send),
                  label: Text(l.chatSend),
                ),
                ],
              ),
            ),
          ),
        ],
          ),
        ],
      ),
    );
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position.maxScrollExtent;
    if (animated) {
      _scrollCtrl.animateTo(
        pos,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(pos);
    }
  }

  String _statusText(ChatState st, AppLocalizations l) {
    final b = st.brand?.trim() ?? '';
    final m = st.model?.trim() ?? '';
    final y = st.year?.trim() ?? '';
    String lvl = '';
    if (st.expertise == 1) {
      lvl = l.chatStatusLevel(l.chatExpertise1);
    } else if (st.expertise == 2) {
      lvl = l.chatStatusLevel(l.chatExpertise2);
    } else if (st.expertise == 3) {
      lvl = l.chatStatusLevel(l.chatExpertise3);
    }
    if (b.isEmpty && m.isEmpty && y.isEmpty) {
      return '${l.chatStatusNone}${lvl.isNotEmpty ? ' $lvl' : ''}';
    }
    final core = [b, m].where((e) => e.isNotEmpty).join(' ');
    final withYear = y.isEmpty ? core : '$core ($y)';
    final locked = st.equipmentLocked ? l.chatStatusLocked : '';
    final base = withYear.isEmpty ? '—' : withYear;
    return '${l.chatStatusTitle(base)}$locked${lvl.isNotEmpty ? ' $lvl' : ''}';
  }
}

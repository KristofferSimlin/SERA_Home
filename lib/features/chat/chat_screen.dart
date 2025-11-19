// lib/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_controller.dart'; // <-- vanlig import, ingen show-filter
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

  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;

  final _brandFocus = FocusNode();
  final _modelFocus = FocusNode();
  final _yearFocus = FocusNode();

  bool _lock = false;

  // Litet hjälp-API för att få en korrekt typad notifier
  ChatController _ctrl() =>
      (ref.read(chatControllerProvider(widget.sessionId).notifier) as ChatController);

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
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _brandFocus.dispose();
    _modelFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _applyEquipment({bool silent = false}) {
    _ctrl().updateEquipment(
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
      year:  _yearCtrl.text.trim().isEmpty  ? null : _yearCtrl.text.trim(),
      lock: _lock,
    );
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

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await _ctrl().send(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.sessionId));

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
    final chat = _ctrl(); // typad notifier för enklare anrop nedan

    return Scaffold(
      appBar: AppBar(
        title: Text('SERA – Chatt  •  ${widget.sessionId}'),
        actions: [
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
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _brandFocus,
                            controller: _brandCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Märke',
                              hintText: 'ex. Volvo, CAT, Wacker Neuson',
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
                            decoration: const InputDecoration(
                              labelText: 'Modell',
                              hintText: 'ex. EC250E, 320 GC',
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
                            decoration: const InputDecoration(
                              labelText: 'Årsmodell',
                              hintText: 'ex. 2019',
                            ),
                            onChanged: (_) => _applyEquipment(silent: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<int>(
                            value: state.expertise,
                            decoration: const InputDecoration(
                              labelText: 'Kunskapsnivå',
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1 – Nybörjare')),
                              DropdownMenuItem(value: 2, child: Text('2 – Medel')),
                              DropdownMenuItem(value: 3, child: Text('3 – Expert')),
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: cs.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _statusText(state),
                            style: const TextStyle(fontSize: 12.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearEquipment,
                          icon: const Icon(Icons.restart_alt, size: 18),
                          label: const Text('Byt'),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: _lock,
                          onChanged: (v) {
                            setState(() => _lock = v);
                            chat.setEquipmentLocked(v);
                          },
                        ),
                        const Text('Lås'),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () => _applyEquipment(),
                          icon: const Icon(Icons.save),
                          label: const Text('Spara'),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'debug → brand:${state.brand ?? "-"} | model:${state.model ?? "-"} | year:${state.year ?? "-"} | level:${state.expertise ?? "-"} | locked:${state.equipmentLocked}',
                          style: TextStyle(fontSize: 11, color: cs.onSurface.withOpacity(0.6)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (state.hasSafetyRisk)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SafetyBanner(),
            ),

          const SizedBox(height: 6),

          Expanded(
            child: ListView.builder(
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

          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'Informationen är vägledande. Följ alltid tillverkarens instruktioner och lokala säkerhetsregler. Egen risk.',
                style: TextStyle(color: Color.fromARGB(179, 241, 238, 238), fontSize: 12.5),
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
                      decoration: const InputDecoration(
                        hintText: 'Skriv ett meddelande…',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: state.isSending ? null : _send,
                    icon: const Icon(Icons.send),
                    label: const Text('Skicka'),
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

  String _statusText(ChatState st) {
    final b = st.brand?.trim() ?? '';
    final m = st.model?.trim() ?? '';
    final y = st.year?.trim() ?? '';
    String lvl;
    if (st.expertise == 1) {
      lvl = ' • Nivå: Nybörjare';
    } else if (st.expertise == 2) {
      lvl = ' • Nivå: Medel';
    } else if (st.expertise == 3) {
      lvl = ' • Nivå: Expert';
    } else {
      lvl = '';
    }
    if (b.isEmpty && m.isEmpty && y.isEmpty) {
      return 'Ingen utrustning vald ännu.$lvl';
    }
    final core = [b, m].where((e) => e.isNotEmpty).join(' ');
    final withYear = y.isEmpty ? core : '$core ($y)';
    return 'Vald: ${withYear.isEmpty ? '—' : withYear}${st.equipmentLocked ? ' • Låst' : ''}$lvl';
  }
}

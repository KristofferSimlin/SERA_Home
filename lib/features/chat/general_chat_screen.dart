import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/l10n/app_localizations.dart';

import 'chat_controller.dart';
import 'widgets/chat_backdrop.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/safety_banner.dart';

class GeneralChatScreen extends ConsumerStatefulWidget {
  const GeneralChatScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<GeneralChatScreen> createState() => _GeneralChatScreenState();
}

class _GeneralChatScreenState extends ConsumerState<GeneralChatScreen> {
  final _input = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _showSafetyBanner = true;

  ChatController _ctrl() =>
      ref.read(chatControllerProvider(widget.sessionId).notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ctrl().suppressEquipmentQuestion();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollCtrl.dispose();
    super.dispose();
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
    final cs = Theme.of(context).colorScheme;

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
            (_) => _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent + 120,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
            ),
          );
        }
      },
    );

    ref.listen<ChatState>(
      chatControllerProvider(widget.sessionId),
      (prev, next) {
        final hadRisk = prev?.hasSafetyRisk ?? false;
        if (!hadRisk && next.hasSafetyRisk) {
          setState(() => _showSafetyBanner = true);
        }
      },
    );

    String? thinkingText;
    switch (state.thinkingCode) {
      case 'thinking':
        thinkingText = l.chatThinkingPreparing;
        break;
      case 'gathering':
        thinkingText = l.chatThinkingGathering;
        break;
      case 'composing':
        thinkingText = l.chatThinkingComposing;
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.generalChatTitle),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: ChatBackdrop(
              intensity: 0.9,
              speed: 0.75,
            ),
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    l.generalChatNotice,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70, height: 1.35),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount:
                      state.messages.length + (thinkingText != null ? 1 : 0),
                  itemBuilder: (_, i) {
                    final isPlaceholder =
                        i == state.messages.length && thinkingText != null;
                    if (isPlaceholder) {
                      final placeholderText =
                          thinkingText ?? l.chatThinkingPreparing;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.2),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                placeholderText,
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.8),
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

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
                    l.generalChatInfo,
                    style: const TextStyle(
                        color: Color.fromARGB(179, 241, 238, 238),
                        fontSize: 12.5),
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
}

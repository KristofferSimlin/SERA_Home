import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;
  final String timeLabel;
  final bool showDisclaimer;

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    required this.timeLabel,
    this.showDisclaimer = false,
  });

  @override
  Widget build(BuildContext context) {
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser
        ? AppTheme.electricBlue.withOpacity(0.12)
        : const Color(0xFF1C2228);

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUser
                  ? AppTheme.electricBlue.withOpacity(0.5)
                  : const Color(0xFF2A3138),
            ),
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              SelectableText(
                text,
                style: const TextStyle(height: 1.35, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUser ? Icons.person : Icons.smart_toy_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeLabel,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              if (showDisclaimer) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFF2A3138)),
                const SizedBox(height: 8),
                const Text(
                  'Källor/Disclaimer:\n• Informationen är vägledande. '
                  'Följ alltid tillverkarens instruktioner och lokala säkerhetsregler. Egen risk.',
                  style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.35),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

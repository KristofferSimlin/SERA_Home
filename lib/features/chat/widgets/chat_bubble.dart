import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.isUser,
    required this.text,
    this.time,
  });

  final bool isUser;
  final String text;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bg = isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest
            .withAlpha((colorScheme.surfaceContainerHighest.a * 255 * 0.4).round());
    final fg = isUser
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: isUser ? const Radius.circular(14) : const Radius.circular(4),
      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(14),
    );

    final ts = time != null ? DateFormat('HH:mm').format(time!) : null;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              SelectableText(
                text.trim().isEmpty ? ' ' : text,
                style: TextStyle(color: fg, height: 1.35, fontSize: 15.0),
              ),
              if (ts != null) ...[
                const SizedBox(height: 6),
                Text(
                  ts,
                  style: TextStyle(
                    color: fg.withAlpha((fg.a * 255 * 0.75).round()),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

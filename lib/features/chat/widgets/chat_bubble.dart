import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class ChatBubble extends StatefulWidget {
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
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final Map<int, bool> _checks = {};

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final isTableLike = _looksLikeTable(text);
    final colorScheme = Theme.of(context).colorScheme;
    final bg = widget.isUser
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest.withOpacity(0.4);
    final fg = widget.isUser ? colorScheme.onPrimary : colorScheme.onSurface;

    final align = widget.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft:
          widget.isUser ? const Radius.circular(14) : const Radius.circular(4),
      bottomRight:
          widget.isUser ? const Radius.circular(4) : const Radius.circular(14),
    );

    final ts =
        widget.time != null ? DateFormat('HH:mm').format(widget.time!) : null;
    final tableParts = _extractTableBlock(text);
    final segments = _parseSegments(text);

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Column(
            crossAxisAlignment: widget.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (tableParts == null)
                ...segments
                    .map((s) => s.checklist != null
                        ? _checklistView(s.checklist!, fg)
                        : _plainText(context, s.text ?? '', fg, isTableLike))
                    .toList()
              else ...[
                if (tableParts.before.isNotEmpty)
                  _plainText(context, tableParts.before, fg, false),
                _tableView(context, tableParts.tableLines, fg),
                if (tableParts.after.isNotEmpty)
                  _plainText(context, tableParts.after, fg, false),
              ],
              if (ts != null) ...[
                const SizedBox(height: 6),
                Text(
                  ts,
                  style: TextStyle(
                    color: fg.withOpacity(0.75),
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

  bool _looksLikeTable(String text) {
    if (text.contains('```')) return true;
    final lines = text.split('\n').map((l) => l.trim()).toList();
    final hasPipes = lines.any((l) => l.startsWith('|') && l.contains('|'));
    final hasSeparator =
        lines.any((l) => l.startsWith('|') && l.contains('---'));
    return hasPipes && hasSeparator;
  }

  Widget _plainText(
      BuildContext context, String value, Color fg, bool isTableLike) {
    final theme = Theme.of(context);
    final lines = value.split('\n');
    final children = <Widget>[];
    final headingRegex = RegExp(r'^\s*(#{1,6})\s*(.+)$');

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.isEmpty) continue;
      final m = headingRegex.firstMatch(line);
      if (m != null) {
        final level = m.group(1)!.length;
        final text = m.group(2)!.trim();
        TextStyle base;
        if (level <= 2) {
          base = theme.textTheme.titleLarge ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
        } else if (level == 3) {
          base = theme.textTheme.titleMedium ??
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
        } else {
          base = theme.textTheme.titleSmall ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
        }
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: SelectableText(
            text,
            style: base.copyWith(color: fg),
          ),
        ));
      } else {
        final pretty = _prettify(line);
        children.add(SelectableText(
          pretty.trim().isEmpty ? ' ' : pretty,
          style: TextStyle(
            color: fg,
            height: isTableLike ? 1.25 : 1.35,
            fontSize: isTableLike ? 14.5 : 15.0,
            fontFamily: isTableLike ? 'monospace' : null,
            fontFeatures:
                isTableLike ? const [] : const [FontFeature.tabularFigures()],
          ),
        ));
      }
    }

    if (children.isEmpty) {
      children.add(SelectableText(
        ' ',
        style: TextStyle(color: fg, height: 1.35),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _tableView(BuildContext context, List<String> tableLines, Color fg) {
    final rows = _parseTable(tableLines);
    if (rows.isEmpty) {
      return _plainText(context, tableLines.join('\n'), fg, true);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.symmetric(
          inside: BorderSide(color: fg.withOpacity(0.25), width: 0.6),
          outside: BorderSide(color: fg.withOpacity(0.35), width: 0.8),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          for (final row in rows)
            TableRow(
              decoration: const BoxDecoration(),
              children: [
                for (final cell in row)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: SelectableText(
                      cell,
                      style: TextStyle(
                        color: fg,
                        height: 1.3,
                        fontSize: 14.5,
                        fontFamily: 'monospace',
                        fontFeatures: const [],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  List<List<String>> _parseTable(List<String> lines) {
    final cleaned = <List<String>>[];
    for (final raw in lines) {
      var line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('|')) line = line.substring(1);
      if (line.endsWith('|')) line = line.substring(0, line.length - 1);
      final cells = line.split('|').map((c) => c.trim()).toList();
      final isSeparator =
          cells.every((c) => RegExp(r'^:?-{2,}:?$').hasMatch(c));
      if (isSeparator) continue;
      cleaned.add(cells);
    }
    if (cleaned.isEmpty) return [];
    final cols =
        cleaned.map((r) => r.length).fold<int>(0, (a, b) => b > a ? b : a);
    return cleaned
        .map((r) => [
              ...r,
              ...List.filled(cols - r.length, ''),
            ])
        .toList();
  }

  _TableParts? _extractTableBlock(String text) {
    final lines = text.split('\n');
    int start = -1;
    int end = -1;
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i].trim();
      if (l.startsWith('|') && l.contains('|')) {
        if (start == -1) start = i;
        end = i;
      } else {
        if (start != -1 && end != -1) break;
      }
    }
    if (start == -1 || end == -1 || start == end) return null;
    final before = lines.sublist(0, start).join('\n').trim();
    final tableLines = lines.sublist(start, end + 1);
    final after = lines.sublist(end + 1).join('\n').trim();
    return _TableParts(before: before, tableLines: tableLines, after: after);
  }

  List<_Segment> _parseSegments(String text) {
    final lines = text.split('\n');
    final segments = <_Segment>[];
    List<_ChecklistItem>? currentChecklist;
    final buffer = StringBuffer();
    final regex = RegExp(r'^\s*[-*]\s*\[( |x|X)\]\s*(.+)$');

    void flushText() {
      final t = buffer.toString().trimRight();
      if (t.isNotEmpty) segments.add(_Segment.text(t));
      buffer.clear();
    }

    void flushChecklist() {
      if (currentChecklist != null && currentChecklist!.isNotEmpty) {
        segments.add(_Segment.checklist(currentChecklist!));
      }
      currentChecklist = null;
    }

    for (final line in lines) {
      final m = regex.firstMatch(line);
      if (m != null) {
        if (buffer.isNotEmpty) flushText();
        currentChecklist ??= [];
        final checked = m.group(1)!.toLowerCase() == 'x';
        final label = m.group(2)!.trim();
        currentChecklist!.add(_ChecklistItem(label, checked));
      } else {
        if (currentChecklist != null) {
          flushChecklist();
        }
        buffer.writeln(line);
      }
    }
    if (currentChecklist != null) {
      flushChecklist();
    }
    if (buffer.isNotEmpty) {
      flushText();
    }
    return segments;
  }

  Widget _checklistView(List<_ChecklistItem> items, Color fg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            controlAffinity: ListTileControlAffinity.leading,
            value: _checks[i] ?? items[i].checked,
            onChanged: (v) {
              setState(() {
                _checks[i] = v ?? false;
              });
            },
            title: Text(
              items[i].label,
              style: TextStyle(color: fg, height: 1.3),
            ),
          ),
      ],
    );
  }

  String _prettify(String input) {
    var s = input;
    // Bullets: replace leading "- " with "• "
    // Replace leading "- " (line-start) with bullet; avoid inline flags for web
    s = s.replaceAllMapped(
        RegExp(r'(^|\n)\s*-\s+'), (m) => '${m.group(1) ?? ''}• ');
    // Bold markers **text** or __text__ → text
    s = s.replaceAll(RegExp(r'\*\*'), '');
    s = s.replaceAll(RegExp(r'__'), '');
    // Strip lone backticks used for inline code
    s = s.replaceAll('`', '');
    return s;
  }
}

class _TableParts {
  _TableParts(
      {required this.before, required this.tableLines, required this.after});
  final String before;
  final List<String> tableLines;
  final String after;
}

class _Segment {
  const _Segment.text(this.text) : checklist = null;
  const _Segment.checklist(this.checklist) : text = null;
  final String? text;
  final List<_ChecklistItem>? checklist;
}

class _ChecklistItem {
  _ChecklistItem(this.label, this.checked);
  final String label;
  bool checked;
}

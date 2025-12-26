import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sera/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

import '../chat/widgets/chat_backdrop.dart';
import 'work_order_controller.dart';

class WorkOrderScreen extends ConsumerStatefulWidget {
  const WorkOrderScreen({
    super.key,
    this.prefill,
    this.autoGenerate = false,
    this.fromChat = false,
  });

  final String? prefill;
  final bool autoGenerate;
  final bool fromChat;

  @override
  ConsumerState<WorkOrderScreen> createState() => _WorkOrderScreenState();
}

class _WorkOrderScreenState extends ConsumerState<WorkOrderScreen> {
  final _descCtrl = TextEditingController();
  final _resultCtrl = TextEditingController();
  final _descFocus = FocusNode();
  bool _prefillApplied = false;
  bool _autoTriggered = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _resultCtrl.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_prefillApplied && widget.prefill?.isNotEmpty == true) {
        _prefillApplied = true;
        _descCtrl.text = widget.prefill!.trim();
        ref
            .read(workOrderControllerProvider.notifier)
            .updateDescription(_descCtrl.text);
      }
      if (widget.autoGenerate && !_autoTriggered) {
        _autoTriggered = true;
        _handleAutoGenerate();
      }
    });
  }

  bool _hasFinalFault(String text) {
    final t = text.toLowerCase();
    const keywords = [
      'slutliga felet',
      'slutligt fel',
      'felet var',
      'orsaken var',
      'root cause',
      'löste',
      'bytte',
      'ersatte',
    ];
    return keywords.any(t.contains);
  }

  Future<void> _handleAutoGenerate() async {
    final notifier = ref.read(workOrderControllerProvider.notifier);
    var current = _descCtrl.text;
    if (widget.fromChat && !_hasFinalFault(current)) {
      final l = AppLocalizations.of(context);
      final input = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Slutligt fel?'),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Vad var grundorsaken/felet?',
                hintText: 'Exempel: Trasig tryckgivare P123',
              ),
              onSubmitted: (v) => Navigator.of(ctx).pop(v),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hoppa över'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(ctrl.text),
                child: const Text('Lägg till'),
              ),
            ],
          );
        },
      );
      final trimmed = input?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        current = '$current\n\nSlutligt fel: $trimmed';
        _descCtrl.text = current;
        _descCtrl.selection =
            TextSelection.collapsed(offset: _descCtrl.text.length);
        notifier.updateDescription(current);
      }
    }
    notifier.generate();
  }

  Future<void> _copyResult(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.workOrderCopied)));
  }

  Future<void> _exportPdf(String text) async {
    final l = AppLocalizations.of(context);
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd – HH:mm').format(now);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            l.workOrderPdfTitle,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${l.workOrderGeneratedAt} $dateStr',
            style: pw.TextStyle(color: PdfColors.blueGrey600, fontSize: 11),
          ),
          pw.SizedBox(height: 14),
          pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blueGrey200),
            ),
            padding: const pw.EdgeInsets.all(14),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                for (final line in text.trim().split('\n'))
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Text(
                      line,
                      style: const pw.TextStyle(
                        fontSize: 11.5,
                        lineSpacing: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: l.workOrderPdfFileName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l.error}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WorkOrderState>(workOrderControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        final l = AppLocalizations.of(context);
        final message = next.error!.contains('401')
            ? l.workOrderErrorUnauthorized
            : l.workOrderErrorGeneric;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$message (${next.error})')),
        );
        ref.read(workOrderControllerProvider.notifier).clearError();
      }
    });

    final state = ref.watch(workOrderControllerProvider);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (state.result != null && state.result != _resultCtrl.text) {
      _resultCtrl.text = state.result!;
      _resultCtrl.selection =
          TextSelection.collapsed(offset: _resultCtrl.text.length);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.workOrderTitle),
        actions: [
          IconButton(
            tooltip: l.homeSettings,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: ChatBackdrop(
              intensity: 0.9,
              speed: 0.75,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.workOrderHeadline,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l.workOrderSubhead,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (state.isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child:
                                    CircularProgressIndicator(strokeWidth: 3),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _descCtrl,
                        focusNode: _descFocus,
                        minLines: 4,
                        maxLines: 8,
                        onChanged: (v) => ref
                            .read(workOrderControllerProvider.notifier)
                            .updateDescription(v),
                        decoration: InputDecoration(
                          labelText: l.workOrderDescriptionLabel,
                          hintText: l.workOrderDescriptionHint,
                        ),
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    FocusScope.of(context).unfocus();
                                    ref
                                        .read(workOrderControllerProvider
                                            .notifier)
                                        .generate();
                                  },
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(l.workOrderGenerate),
                          ),
                          OutlinedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    _descCtrl.clear();
                                    _resultCtrl.clear();
                                    ref
                                        .read(workOrderControllerProvider
                                            .notifier)
                                        .updateDescription('');
                                    ref
                                        .read(workOrderControllerProvider
                                            .notifier)
                                        .clearResult();
                                  },
                            icon: const Icon(Icons.refresh),
                            label: Text(l.workOrderClear),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (state.result != null) ...[
                        TextField(
                          controller: _resultCtrl,
                          minLines: 6,
                          maxLines: 14,
                          onChanged: (v) => ref
                              .read(workOrderControllerProvider.notifier)
                              .setResult(v),
                          decoration: const InputDecoration(
                            labelText: 'Redigera/komplettera rapport (Markdown)',
                            helperText:
                                'Justera texten innan du kopierar eller exporterar.',
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: state.result == null
                            ? _PreviewPlaceholder(text: l.workOrderPreviewEmpty)
                            : _PreviewCard(
                                text: state.result!,
                                onCopy: () => _copyResult(state.result!),
                                onExport: () => _exportPdf(state.result!),
                                l: l,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.text,
    required this.onCopy,
    required this.onExport,
    required this.l,
  });

  final String text;
  final VoidCallback onCopy;
  final VoidCallback onExport;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  l.workOrderPreviewTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onCopy,
                      icon: const Icon(Icons.copy_outlined),
                      label: Text(l.workOrderCopy),
                    ),
                    FilledButton.icon(
                      onPressed: onExport,
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(l.workOrderExportPdf),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.all(14),
              child: MarkdownBody(
                data: text,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  theme.copyWith(
                    textTheme: theme.textTheme.apply(
                      bodyColor: Colors.white,
                      displayColor: Colors.white,
                    ),
                  ),
                ).copyWith(
                  p: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  listBullet: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sera/l10n/app_localizations.dart';

import '../chat/widgets/chat_backdrop.dart';
import 'service_controller.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});

  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _customTypeCtrl = TextEditingController();

  // TODO: Prefill brand/model/year from senaste chatt-session om tillgängligt.

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _customTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _copy(String text, AppLocalizations l) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.serviceCopied)));
  }

  Future<void> _exportPdf(String text, AppLocalizations l) async {
    final doc = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd – HH:mm').format(now);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            l.serviceTitle,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${l.serviceGeneratedAt} $dateStr',
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
        filename: l.servicePdfFileName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${l.error}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ServiceState>(serviceControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        final l = AppLocalizations.of(context);
        final message = next.error!.contains('401')
            ? l.serviceErrorUnauthorized
            : l.serviceErrorGeneric;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$message (${next.error})')));
        ref.read(serviceControllerProvider.notifier).clearError();
      }
    });

    final state = ref.watch(serviceControllerProvider);
    final notifier = ref.read(serviceControllerProvider.notifier);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final serviceTypes = <String>[
      '50 h',
      '250 h',
      '500 h',
      '1000 h',
      l.serviceTypeYearly,
      l.serviceTypeAfterRepair,
      serviceTypeCustomKey,
    ];
    final isCustom = state.serviceType == serviceTypeCustomKey;
    final canGenerate = state.brand.trim().isNotEmpty &&
        state.model.trim().isNotEmpty &&
        notifier.hasRequiredFields;

    // Håll fälten i synk när clear() körts.
    if (!state.isGenerating) {
      if (_brandCtrl.text != state.brand) {
        _brandCtrl.text = state.brand;
        _brandCtrl.selection =
            TextSelection.collapsed(offset: _brandCtrl.text.length);
      }
      if (_modelCtrl.text != state.model) {
        _modelCtrl.text = state.model;
        _modelCtrl.selection =
            TextSelection.collapsed(offset: _modelCtrl.text.length);
      }
      if ((_yearCtrl.text.isEmpty && (state.year ?? '').isEmpty) == false &&
          _yearCtrl.text != (state.year ?? '')) {
        _yearCtrl.text = state.year ?? '';
        _yearCtrl.selection =
            TextSelection.collapsed(offset: _yearCtrl.text.length);
      }
      if (isCustom && _customTypeCtrl.text != (state.customServiceType ?? '')) {
        _customTypeCtrl.text = state.customServiceType ?? '';
        _customTypeCtrl.selection =
            TextSelection.collapsed(offset: _customTypeCtrl.text.length);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.serviceTitle),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              l.serviceHeadline,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (state.isGenerating)
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 260,
                            child: TextField(
                              controller: _brandCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l.serviceBrandLabel,
                                hintText: l.serviceBrandHint,
                              ),
                              onChanged: notifier.updateBrand,
                            ),
                          ),
                          SizedBox(
                            width: 260,
                            child: TextField(
                              controller: _modelCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l.serviceModelLabel,
                                hintText: l.serviceModelHint,
                              ),
                              onChanged: notifier.updateModel,
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _yearCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l.serviceYearLabel,
                                hintText: l.serviceYearHint,
                              ),
                              onChanged: notifier.updateYear,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: state.serviceType,
                        decoration:
                            InputDecoration(labelText: l.serviceTypeLabel),
                        items: serviceTypes
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  t == serviceTypeCustomKey
                                      ? l.serviceTypeCustom
                                      : t,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          notifier.updateServiceType(v);
                        },
                      ),
                      if (isCustom) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _customTypeCtrl,
                          decoration: InputDecoration(
                            labelText: l.serviceTypeCustomLabel,
                            hintText: l.serviceTypeCustomHint,
                          ),
                          onChanged: notifier.updateCustomServiceType,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: canGenerate
                                ? () {
                                    FocusScope.of(context).unfocus();
                                    notifier.generate();
                                  }
                                : null,
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(l.serviceGenerate),
                          ),
                          OutlinedButton.icon(
                            onPressed: state.isGenerating
                                ? null
                                : () {
                                    _brandCtrl.clear();
                                    _modelCtrl.clear();
                                    _yearCtrl.clear();
                                    _customTypeCtrl.clear();
                                    notifier.clear();
                                  },
                            icon: const Icon(Icons.refresh),
                            label: Text(l.serviceClear),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l.servicePreviewTitle,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: (state.output ?? '').isEmpty
                                            ? null
                                            : () => _copy(state.output!, l),
                                        icon: const Icon(Icons.copy_outlined),
                                        label: Text(l.serviceCopy),
                                      ),
                                      FilledButton.icon(
                                        onPressed: (state.output ?? '').isEmpty
                                            ? null
                                            : () =>
                                                _exportPdf(state.output!, l),
                                        icon: const Icon(
                                            Icons.picture_as_pdf_outlined),
                                        label: Text(l.serviceExportPdf),
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
                                child: SelectableText(
                                  state.output?.isNotEmpty == true
                                      ? state.output!
                                      : l.servicePreviewEmpty,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                    color: state.output == null
                                        ? Colors.white70
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

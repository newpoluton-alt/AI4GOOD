import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../../data/models/analysis_models.dart';
import '../data_review_strings.dart';
import '../providers/analysis_controller.dart';
import '../widgets/app_page_shell.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/loading_overlay.dart';

class AnalysisReportPage extends ConsumerStatefulWidget {
  const AnalysisReportPage({super.key, required this.report});

  final AnalysisReport report;

  @override
  ConsumerState<AnalysisReportPage> createState() => _AnalysisReportPageState();
}

class _AnalysisReportPageState extends ConsumerState<AnalysisReportPage> {
  bool _isExporting = false;
  bool _hasExported = false;

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    final compact = responsive.isMobile;
    final panelPadding = compact ? 18.0 : 28.0;
    final reportText = widget.report.reportMarkdown.isNotEmpty
        ? widget.report.reportMarkdown
        : widget.report.reportHtml;

    return AppPageShell(
      eyebrow: strings.aiDataAnalysis,
      title: strings.aiDataAnalysis,
      onBack: () => _goBack(context),
      child: LoadingOverlay(
        isLoading: _isExporting,
        label: strings.loading,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: AppSurface(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      panelPadding,
                      panelPadding,
                      panelPadding,
                      compact ? 18 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.reportTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: 0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.aiCaution,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(compact ? 14 : 24),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                              child: Text(
                                strings.report,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Markdown(
                                data: reportText.isEmpty ? '-' : reportText,
                                padding: EdgeInsets.all(compact ? 14 : 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 18 : 24,
                      vertical: 18,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => _goBack(context),
                          child: Text(strings.back),
                        ),
                        FilledButton.icon(
                          onPressed: _isExporting ? null : () => _exportPdf(),
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: Text(strings.exportPdf),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _copyReport(reportText),
                          icon: const Icon(Icons.copy_rounded),
                          label: Text(strings.copy),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _goBack(BuildContext context) async {
    final strings = context.drStrings;
    if (!_hasExported) {
      final confirmed = await showAdaptiveConfirmationDialog(
        context: context,
        title: strings.goBackWithoutExportQuestion,
        cancelLabel: strings.cancel,
        confirmLabel: strings.back,
      );
      if (!confirmed) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _exportPdf() async {
    final strings = context.drStrings;
    setState(() => _isExporting = true);
    try {
      final bytes = await ref
          .read(analysisControllerProvider.notifier)
          .downloadReportPdf(widget.report.analysisJobId);
      await FileSaver.instance.saveFile(
        name: 'analysis_report_${widget.report.analysisJobId}',
        bytes: Uint8List.fromList(bytes),
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (!mounted) return;
      setState(() {
        _hasExported = true;
        _isExporting = false;
      });
      showAppSnackBar(context, message: strings.pdfSaved);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }

  Future<void> _copyReport(String reportText) async {
    final strings = context.drStrings;
    await Clipboard.setData(ClipboardData(text: reportText));
    if (!mounted) return;
    showAppSnackBar(context, message: strings.copied);
  }
}

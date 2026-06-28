import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../data_review_strings.dart';
import '../providers/analysis_controller.dart';
import '../widgets/app_page_shell.dart';
import '../widgets/loading_overlay.dart';
import 'analysis_report_page.dart';

class AnalysisInstructionPage extends ConsumerStatefulWidget {
  const AnalysisInstructionPage({super.key, required this.datasetIds});

  final List<String> datasetIds;

  @override
  ConsumerState<AnalysisInstructionPage> createState() =>
      _AnalysisInstructionPageState();
}

class _AnalysisInstructionPageState
    extends ConsumerState<AnalysisInstructionPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    final state = ref.watch(analysisControllerProvider).valueOrNull;
    final isBusy = state?.isBusy ?? false;
    final status = state?.jobStatus;

    return AppPageShell(
      eyebrow: strings.aiDataAnalysis,
      title: strings.aiDataAnalysis,
      child: LoadingOverlay(
        isLoading: isBusy,
        label: status == null
            ? strings.loading
            : '${status.status} ${status.progress}%',
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = responsive.isMobile || constraints.maxWidth < 640;
            final panelPadding = compact ? 20.0 : 28.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 980,
                  maxHeight: constraints.maxHeight,
                ),
                child: AppSurface(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            panelPadding,
                            panelPadding,
                            panelPadding,
                            compact ? 20 : 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.instructionsTitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                      letterSpacing: 0,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strings.instructionsSubtitle,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: EdgeInsets.all(panelPadding),
                          child: Container(
                            padding: EdgeInsets.all(compact ? 14 : 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.typeInstructions,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text,
                                      ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _controller,
                                  minLines: compact ? 6 : 8,
                                  maxLines: compact ? 8 : 12,
                                  textInputAction: TextInputAction.newline,
                                  decoration: const InputDecoration(
                                    alignLabelWithHint: true,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                ),
                              ],
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
                                onPressed: isBusy
                                    ? null
                                    : () => Navigator.of(context).maybePop(),
                                child: Text(strings.back),
                              ),
                              FilledButton.icon(
                                onPressed: isBusy
                                    ? null
                                    : () => _analyze(context),
                                icon: const Icon(Icons.auto_awesome_rounded),
                                label: Text(strings.analyzeNow),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _analyze(BuildContext context) async {
    final strings = context.drStrings;
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      showAppSnackBar(
        context,
        message: strings.enterInstructions,
        isError: true,
      );
      return;
    }
    try {
      final report = await ref
          .read(analysisControllerProvider.notifier)
          .startAnalysis(
            datasetIds: widget.datasetIds,
            prompt: prompt,
            language: strings.languageCode,
          );
      if (!context.mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AnalysisReportPage(report: report)),
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }
}

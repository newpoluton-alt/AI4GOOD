import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../../data/models/dataset_models.dart';
import '../data_review_strings.dart';
import '../providers/data_preview_controller.dart';
import '../widgets/app_page_shell.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/dataset_table.dart';
import '../widgets/empty_state.dart';
import '../widgets/issue_review_dialog.dart';
import '../widgets/loading_overlay.dart';

class DataPreviewPage extends ConsumerStatefulWidget {
  const DataPreviewPage({super.key, required this.bundle});

  final DatasetPreviewBundle bundle;

  @override
  ConsumerState<DataPreviewPage> createState() => _DataPreviewPageState();
}

class _DataPreviewPageState extends ConsumerState<DataPreviewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(dataPreviewControllerProvider.notifier)
          .setInitial(
            datasetId: widget.bundle.datasetId,
            reviewSessionId: widget.bundle.reviewSessionId,
            sheets: widget.bundle.sheets,
            preview: widget.bundle.preview,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    final asyncState = ref.watch(dataPreviewControllerProvider);

    return AppPageShell(
      eyebrow: strings.dataPreview,
      title: strings.dataPreview,
      child: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          retryLabel: strings.retry,
          onRetry: () => ref
              .read(dataPreviewControllerProvider.notifier)
              .setInitial(
                datasetId: widget.bundle.datasetId,
                reviewSessionId: widget.bundle.reviewSessionId,
                sheets: widget.bundle.sheets,
                preview: widget.bundle.preview,
              ),
        ),
        data: (state) {
          final preview = state.preview;
          return LoadingOverlay(
            isLoading: state.isActionRunning || state.isFinalizing,
            label: state.isFinalizing ? strings.loading : null,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AppInfoPill(
                          icon: Icons.check_circle_rounded,
                          label: strings.uploadComplete,
                          color: const Color(0xFFE9F7F4),
                          textColor: AppColors.success,
                        ),
                      ),
                    ),
                    Expanded(
                      child: preview == null
                          ? EmptyState(message: strings.noRows)
                          : DatasetTable(
                              preview: preview,
                              sheets: state.sheets,
                              isLoading: state.isActionRunning,
                              onSheetChanged: (sheet) =>
                                  _loadPreview(sheet: sheet),
                              onPageChanged: (page) => _loadPreview(page: page),
                            ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: responsive.isMobile
                          ? Alignment.center
                          : AlignmentDirectional.centerEnd,
                      child: SizedBox(
                        width: responsive.isMobile ? double.infinity : null,
                        child: FilledButton.icon(
                          onPressed: state.isActionRunning || preview == null
                              ? null
                              : () => _runReview(context),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(strings.aiReview),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadPreview({String? sheet, int page = 1}) async {
    try {
      await ref
          .read(dataPreviewControllerProvider.notifier)
          .loadPreview(sheet: sheet, page: page);
    } catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }

  Future<void> _runReview(BuildContext context) async {
    final strings = context.drStrings;
    try {
      final result = await ref
          .read(dataPreviewControllerProvider.notifier)
          .runReview(language: strings.languageCode);
      if (!context.mounted) return;
      if (result.status == 'clean' || result.pendingCount == 0) {
        await _finalizeAfterMessage(context, strings.noIssuesFound);
        return;
      }
      final shouldFinalize = await showIssueReviewDialog(context);
      if (shouldFinalize && context.mounted) {
        await _finalizeAfterMessage(context, strings.changesMade);
      }
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }

  Future<void> _finalizeAfterMessage(
    BuildContext context,
    String message,
  ) async {
    final strings = context.drStrings;
    await showAdaptiveConfirmationDialog(
      context: context,
      title: message,
      cancelLabel: '',
      confirmLabel: strings.close,
    );
    if (!context.mounted) return;
    try {
      final result = await ref
          .read(dataPreviewControllerProvider.notifier)
          .finalizeReview(language: strings.languageCode);
      if (!context.mounted) return;
      final uri = Uri.parse(result.downloadUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      showAppSnackBar(context, message: strings.openDownload);
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }
}

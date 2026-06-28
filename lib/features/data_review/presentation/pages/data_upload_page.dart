import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../../data/models/dataset_models.dart';
import '../data_review_strings.dart';
import '../providers/data_upload_controller.dart';
import '../widgets/app_page_shell.dart';
import '../widgets/loading_overlay.dart';
import 'data_preview_page.dart';

class DataUploadPage extends ConsumerWidget {
  const DataUploadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    final uploadState =
        ref.watch(dataUploadControllerProvider).valueOrNull ??
        const DataUploadState();

    return AppPageShell(
      eyebrow: strings.dataUpload,
      title: strings.dataUpload,
      child: LoadingOverlay(
        isLoading: uploadState.isUploading,
        label: strings.uploading,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900, maxHeight: 380),
            child: AppSurface(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  onTap: uploadState.isUploading
                      ? null
                      : () =>
                            _pickAndUpload(context, ref, strings.languageCode),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;
                      final tight = constraints.maxWidth < 380;
                      final cardPadding = responsive.isMobile ? 22.0 : 34.0;
                      final prompt = Text(
                        strings.uploadPrompt,
                        textAlign: compact ? TextAlign.center : TextAlign.left,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: 0,
                            ),
                      );
                      final icon = AppIconTile(
                        icon: Icons.upload_rounded,
                        color: AppColors.primary,
                        size: tight ? 68 : 86,
                      );

                      return Padding(
                        padding: EdgeInsets.all(cardPadding),
                        child: compact
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  icon,
                                  const SizedBox(height: 22),
                                  prompt,
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  icon,
                                  const SizedBox(width: 34),
                                  Flexible(child: prompt),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    String language,
  ) async {
    try {
      final result = await ref
          .read(dataUploadControllerProvider.notifier)
          .pickAndUpload(language: language);
      if (result == null || !context.mounted) return;
      final bundle = DatasetPreviewBundle(
        datasetId: result.datasetId,
        reviewSessionId: result.reviewSessionId,
        sheets: result.sheets,
        preview: result.preview,
      );
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DataPreviewPage(bundle: bundle)),
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }
}

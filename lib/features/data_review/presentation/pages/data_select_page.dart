import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../../data/models/analysis_models.dart';
import '../data_review_strings.dart';
import '../providers/analysis_controller.dart';
import '../widgets/app_page_shell.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_overlay.dart';
import 'analysis_instruction_page.dart';
import 'data_preview_page.dart';

class DataSelectPage extends ConsumerWidget {
  const DataSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final state = ref.watch(analysisControllerProvider);

    return AppPageShell(
      eyebrow: strings.aiDataAnalysis,
      title: strings.selectDataForAnalysis,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          retryLabel: strings.retry,
          onRetry: () => ref
              .read(analysisControllerProvider.notifier)
              .loadEligibleDatasets(),
        ),
        data: (data) => LoadingOverlay(
          isLoading: data.isBusy,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _SelectableTable(
                items: data.eligibleDatasets,
                selectedIds: data.selectedDatasetIds,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableTable extends ConsumerWidget {
  const _SelectableTable({required this.items, required this.selectedIds});

  final List<EligibleDatasetItem> items;
  final Set<String> selectedIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final useCards =
            responsive.useCompactLists || constraints.maxWidth < 760;
        return AppSurface(
          padding: EdgeInsets.all(responsive.isMobile ? 14 : 24),
          child: Column(
            children: [
              if (!useCards) ...[
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 80),
                      _HeaderCell(strings.number),
                      _HeaderCell(strings.fileName),
                      _HeaderCell(strings.rows),
                      _HeaderCell(strings.project),
                      const SizedBox(width: 120),
                    ],
                  ),
                ),
                const Divider(),
              ],
              Expanded(
                child: items.isEmpty
                    ? EmptyState(message: strings.noEligibleDatasets)
                    : useCards
                    ? _SelectableCardList(
                        items: items,
                        selectedIds: selectedIds,
                        onView: (item) => _view(context, ref, item),
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final selected = selectedIds.contains(item.datasetId);
                          return ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 76),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Checkbox(
                                    value: selected,
                                    onChanged: (value) => ref
                                        .read(
                                          analysisControllerProvider.notifier,
                                        )
                                        .toggleDataset(
                                          item.datasetId,
                                          value ?? false,
                                        ),
                                  ),
                                ),
                                _BodyCell('${index + 1}'),
                                _BodyCell(item.originalFilename),
                                _BodyCell(item.rowCount.toString()),
                                _BodyCell(item.projectId),
                                SizedBox(
                                  width: 120,
                                  child: Center(
                                    child: FilledButton.icon(
                                      onPressed: () =>
                                          _view(context, ref, item),
                                      icon: const Icon(
                                        Icons.visibility_rounded,
                                      ),
                                      label: Text(strings.view),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: useCards
                    ? Alignment.center
                    : AlignmentDirectional.centerEnd,
                child: SizedBox(
                  width: useCards ? double.infinity : null,
                  child: FilledButton.icon(
                    onPressed: selectedIds.isEmpty
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AnalysisInstructionPage(
                                datasetIds: selectedIds.toList(growable: false),
                              ),
                            ),
                          ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(strings.nextStep),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _view(
    BuildContext context,
    WidgetRef ref,
    EligibleDatasetItem item,
  ) async {
    try {
      final bundle = await ref
          .read(analysisControllerProvider.notifier)
          .previewDataset(item);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DataPreviewPage(bundle: bundle)),
      );
    } catch (error) {
      if (!context.mounted) return;
      showAppSnackBar(context, message: error.toString(), isError: true);
    }
  }
}

class _SelectableCardList extends ConsumerWidget {
  const _SelectableCardList({
    required this.items,
    required this.selectedIds,
    required this.onView,
  });

  final List<EligibleDatasetItem> items;
  final Set<String> selectedIds;
  final ValueChanged<EligibleDatasetItem> onView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = selectedIds.contains(item.datasetId);
        return Material(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadii.medium),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            onTap: () => ref
                .read(analysisControllerProvider.notifier)
                .toggleDataset(item.datasetId, !selected),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (value) => ref
                        .read(analysisControllerProvider.notifier)
                        .toggleDataset(item.datasetId, value ?? false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.originalFilename,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppInfoPill(
                              label: '${strings.rows}: ${item.rowCount}',
                            ),
                            AppInfoPill(
                              label: item.projectId,
                              color: const Color(0xFFE9F7F4),
                              textColor: AppColors.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: strings.view,
                    onPressed: () => onView(item),
                    icon: const Icon(Icons.visibility_rounded),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

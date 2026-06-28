import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../../data/models/dataset_models.dart';
import '../data_review_strings.dart';
import '../providers/my_data_controller.dart';
import '../widgets/app_page_shell.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_overlay.dart';
import 'data_preview_page.dart';

class MyDataPage extends ConsumerWidget {
  const MyDataPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final state = ref.watch(myDataControllerProvider);

    return AppPageShell(
      eyebrow: strings.myData,
      title: strings.myData,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => AppErrorView(
          message: error.toString(),
          retryLabel: strings.retry,
          onRetry: () => ref.read(myDataControllerProvider.notifier).load(),
        ),
        data: (data) => LoadingOverlay(
          isLoading: data.isBusy,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: _MyDataTable(items: data.items),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyDataTable extends ConsumerWidget {
  const _MyDataTable({required this.items});

  final List<MyDataItem> items;

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
                _HeaderRow(
                  cells: [
                    strings.number,
                    strings.fileName,
                    strings.uploadDate,
                    strings.manage,
                  ],
                ),
                const Divider(),
              ],
              Expanded(
                child: items.isEmpty
                    ? EmptyState(message: strings.noFiles)
                    : useCards
                    ? _MyDataCardList(items: items)
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _MyDataRow(item: item);
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
                    onPressed: items.isEmpty
                        ? null
                        : () async {
                            final confirmed =
                                await showAdaptiveConfirmationDialog(
                                  context: context,
                                  title: strings.deleteAllQuestion,
                                  cancelLabel: strings.cancel,
                                  confirmLabel: strings.deleteAll,
                                  destructive: true,
                                );
                            if (!confirmed) return;
                            try {
                              await ref
                                  .read(myDataControllerProvider.notifier)
                                  .deleteAll();
                            } catch (error) {
                              if (!context.mounted) return;
                              showAppSnackBar(
                                context,
                                message: error.toString(),
                                isError: true,
                              );
                            }
                          },
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: Text(strings.deleteAll),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyDataRow extends ConsumerWidget {
  const _MyDataRow({required this.item});

  final MyDataItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final date = DateFormat('yyyy-MM-dd').format(item.uploadDate);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 76),
      child: Row(
        children: [
          _BodyCell(item.number.toString()),
          _BodyCell(item.originalFilename),
          _BodyCell(date),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  tooltip: strings.delete,
                  onPressed: () => _deleteDataset(context, ref, item),
                  icon: const Icon(Icons.delete_rounded),
                  color: AppColors.danger,
                ),
                FilledButton.icon(
                  onPressed: () => _viewDataset(context, ref, item),
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(strings.view),
                ),
                if (item.processedExportId != null)
                  IconButton(
                    tooltip: strings.openDownload,
                    onPressed: () => _downloadDataset(context, ref, item),
                    icon: const Icon(Icons.download_rounded),
                    color: AppColors.primaryDark,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyDataCardList extends StatelessWidget {
  const _MyDataCardList({required this.items});

  final List<MyDataItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _MyDataCard(item: items[index]),
    );
  }
}

class _MyDataCard extends ConsumerWidget {
  const _MyDataCard({required this.item});

  final MyDataItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final date = DateFormat('yyyy-MM-dd').format(item.uploadDate);
    return Material(
      color: AppColors.surfaceAlt,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.originalFilename,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: strings.delete,
                  onPressed: () => _deleteDataset(context, ref, item),
                  icon: const Icon(Icons.delete_rounded),
                  color: AppColors.danger,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppInfoPill(label: '${strings.number}: ${item.number}'),
                AppInfoPill(
                  label: date,
                  color: const Color(0xFFE9F7F4),
                  textColor: AppColors.primaryDark,
                ),
                if (item.rowCount != null)
                  AppInfoPill(
                    label: '${strings.rows}: ${item.rowCount}',
                    color: const Color(0xFFFFF3E1),
                    textColor: AppColors.warning,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _viewDataset(context, ref, item),
                  icon: const Icon(Icons.visibility_rounded),
                  label: Text(strings.view),
                ),
                if (item.processedExportId != null)
                  OutlinedButton.icon(
                    onPressed: () => _downloadDataset(context, ref, item),
                    icon: const Icon(Icons.download_rounded),
                    label: Text(strings.openDownload),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _viewDataset(
  BuildContext context,
  WidgetRef ref,
  MyDataItem item,
) async {
  try {
    final bundle = await ref
        .read(myDataControllerProvider.notifier)
        .previewDataset(item);
    if (!context.mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => DataPreviewPage(bundle: bundle)));
  } catch (error) {
    if (!context.mounted) return;
    showAppSnackBar(context, message: error.toString(), isError: true);
  }
}

Future<void> _deleteDataset(
  BuildContext context,
  WidgetRef ref,
  MyDataItem item,
) async {
  final strings = context.drStrings;
  final confirmed = await showAdaptiveConfirmationDialog(
    context: context,
    title: strings.deleteOneQuestion,
    cancelLabel: strings.cancel,
    confirmLabel: strings.delete,
    destructive: true,
  );
  if (!confirmed) return;
  try {
    await ref
        .read(myDataControllerProvider.notifier)
        .deleteDataset(item.datasetId);
  } catch (error) {
    if (!context.mounted) return;
    showAppSnackBar(context, message: error.toString(), isError: true);
  }
}

Future<void> _downloadDataset(
  BuildContext context,
  WidgetRef ref,
  MyDataItem item,
) async {
  final strings = context.drStrings;
  try {
    final link = await ref
        .read(myDataControllerProvider.notifier)
        .processedDownload(item.datasetId);
    await launchUrl(
      Uri.parse(link.downloadUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!context.mounted) return;
    showAppSnackBar(context, message: strings.openDownload);
  } catch (error) {
    if (!context.mounted) return;
    showAppSnackBar(context, message: error.toString(), isError: true);
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.cells});

  final List<String> cells;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [for (final cell in cells) _HeaderCell(cell)]),
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

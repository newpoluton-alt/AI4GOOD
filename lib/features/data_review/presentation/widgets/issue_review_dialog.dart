import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../../auth/presentation/widgets/app_snack_bar.dart';
import '../../data/models/review_models.dart';
import '../data_review_strings.dart';
import '../providers/data_preview_controller.dart';

Future<bool> showIssueReviewDialog(BuildContext context) async {
  final responsive = AppResponsive.of(context);
  if (!responsive.isDesktop) {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetResponsive = AppResponsive.of(sheetContext);
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: sheetResponsive.isTablet ? 760 : double.infinity,
            ),
            child: FractionallySizedBox(
              heightFactor: sheetResponsive.isMobile ? 0.94 : 0.88,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: IssueReviewDialog(
                    onFinished: () => Navigator.pop(sheetContext, true),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980, maxHeight: 760),
        child: IssueReviewDialog(
          onFinished: () => Navigator.pop(dialogContext, true),
        ),
      ),
    ),
  );
  return result ?? false;
}

class IssueReviewDialog extends ConsumerWidget {
  const IssueReviewDialog({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final responsive = AppResponsive.of(context);
    final state = ref.watch(dataPreviewControllerProvider);

    return Material(
      color: AppColors.surface,
      elevation: 22,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _DialogError(message: error.toString()),
        data: (previewState) {
          final totalCells = previewState.totalIssueCount;
          final typeCount = previewState.issueGroups.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.isMobile ? 20 : 28,
                  responsive.isMobile ? 20 : 28,
                  responsive.isMobile ? 20 : 28,
                  responsive.isMobile ? 18 : 24,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final titleBlock = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.reviewDetectedErrors,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: 0,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          strings.reviewDetectedErrorsSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    );
                    final metrics = Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          label:
                              '$totalCells ${totalCells == 1 ? strings.cell : strings.cells}',
                          color: const Color(0xFFEAF2FF),
                          textColor: const Color(0xFF1F62D0),
                        ),
                        _Pill(
                          label:
                              '$typeCount ${typeCount == 1 ? strings.type : strings.types}',
                          color: const Color(0xFFFFF3E1),
                          textColor: const Color(0xFF9B5314),
                        ),
                      ],
                    );

                    if (constraints.maxWidth < 560) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleBlock,
                          const SizedBox(height: 14),
                          metrics,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: titleBlock),
                        const SizedBox(width: 16),
                        metrics,
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(responsive.isMobile ? 14 : 22),
                  itemCount: previewState.issueGroups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final group = previewState.issueGroups[index];
                    return IssueGroupCard(group: group, onFinished: onFinished);
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.isMobile ? 18 : 24,
                  16,
                  responsive.isMobile ? 18 : 24,
                  18,
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Text(
                      '${previewState.acceptedCount} ${strings.accepted}, '
                      '${previewState.declinedCount} ${strings.rejected}, '
                      '${previewState.pendingCount} ${strings.pending}',
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Pill(
                          label: strings.reviewRequired,
                          color: const Color(0xFFFFE1E1),
                          textColor: const Color(0xFFC34444),
                        ),
                        if (previewState.pendingCount > 0)
                          _SmallButton(
                            label: strings.rejectAllPending,
                            destructive: true,
                            onPressed: previewState.isActionRunning
                                ? null
                                : () => _runDecision(
                                    context,
                                    ref,
                                    ref
                                        .read(
                                          dataPreviewControllerProvider
                                              .notifier,
                                        )
                                        .declineAllPending(),
                                    onFinished,
                                  ),
                          )
                        else
                          _SmallButton(
                            label: strings.close,
                            onPressed: onFinished,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class IssueGroupCard extends ConsumerStatefulWidget {
  const IssueGroupCard({
    super.key,
    required this.group,
    required this.onFinished,
  });

  final IssueGroupSummary group;
  final VoidCallback onFinished;

  @override
  ConsumerState<IssueGroupCard> createState() => _IssueGroupCardState();
}

class _IssueGroupCardState extends ConsumerState<IssueGroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final previewState = ref.watch(dataPreviewControllerProvider).valueOrNull;
    final group = widget.group;
    final issues = previewState?.issuesByGroup[group.groupId];
    final isLoading =
        previewState?.loadingGroupIds.contains(group.groupId) ?? false;
    final isBusy = previewState?.isActionRunning ?? false;
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _SmallButton(
          label: strings.acceptAll,
          onPressed: group.pendingCount == 0 || isBusy
              ? null
              : () => _runDecision(
                  context,
                  ref,
                  ref
                      .read(dataPreviewControllerProvider.notifier)
                      .acceptIssueGroup(group.groupId),
                  widget.onFinished,
                ),
        ),
        _SmallButton(
          label: strings.rejectAll,
          destructive: true,
          onPressed: group.pendingCount == 0 || isBusy
              ? null
              : () => _runDecision(
                  context,
                  ref,
                  ref
                      .read(dataPreviewControllerProvider.notifier)
                      .declineIssueGroup(group.groupId),
                  widget.onFinished,
                ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) {
          setState(() => _expanded = expanded);
          if (expanded) {
            ref
                .read(dataPreviewControllerProvider.notifier)
                .loadGroupIssues(group.groupId);
          }
        },
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(
              _severityIcon(group.severity),
              color: _severityColor(group.severity),
              size: 22,
            ),
            Text(
              group.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: 0,
              ),
            ),
            _Pill(
              label:
                  '${group.pendingCount} ${group.pendingCount == 1 ? strings.cell : strings.cells}',
              color: const Color(0xFFFFF3E1),
              textColor: const Color(0xFF9B5314),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: actions,
        ),
        trailing: Icon(
          _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        ),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (issues == null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                strings.loading,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            )
          else
            for (final issue in issues)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: _IssueItemTile(
                  issue: issue,
                  onFinished: widget.onFinished,
                ),
              ),
        ],
      ),
    );
  }
}

class _IssueItemTile extends ConsumerWidget {
  const _IssueItemTile({required this.issue, required this.onFinished});

  final IssueItem issue;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = context.drStrings;
    final isPending = issue.status == 'pending';
    final isBusy =
        ref.watch(dataPreviewControllerProvider).valueOrNull?.isActionRunning ??
        false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _issueLabel(strings, issue),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _issueDetail(strings, issue),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.mutedText),
              ),
            ],
          );
          final actions = isPending
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallButton(
                      label: strings.accept,
                      onPressed: isBusy
                          ? null
                          : () => _runDecision(
                              context,
                              ref,
                              ref
                                  .read(dataPreviewControllerProvider.notifier)
                                  .acceptIssue(issue.issueId),
                              onFinished,
                            ),
                    ),
                    _SmallButton(
                      label: strings.reject,
                      destructive: true,
                      onPressed: isBusy
                          ? null
                          : () => _runDecision(
                              context,
                              ref,
                              ref
                                  .read(dataPreviewControllerProvider.notifier)
                                  .declineIssue(issue.issueId),
                              onFinished,
                            ),
                    ),
                  ],
                )
              : _Pill(
                  label: issue.status,
                  color: const Color(0xFFEAF2FF),
                  textColor: const Color(0xFF1F62D0),
                );

          if (constraints.maxWidth < 620) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 12), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: content),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );
  }

  String _issueLabel(DataReviewStrings strings, IssueItem issue) {
    final row = issue.sourceRowNumber?.toString() ?? '-';
    final column = issue.columnName ?? '-';
    return 'ID ${strings.cell} - ${strings.row.toLowerCase()} $row '
        '${strings.isFrench ? 'colonne' : 'column'} $column';
  }

  String _issueDetail(DataReviewStrings strings, IssueItem issue) {
    final explanation = issue.explanation;
    final suggested = issue.suggestedValue;
    final action = switch (issue.operationType) {
      'mark_abnormal_cell' => '${strings.markAbnormal} / ${strings.flagOnly}',
      'exclude_row' || 'delete_duplicate_row' => strings.excludeRow,
      _ => issue.operationType.replaceAll('_', ' '),
    };
    final parts = [
      if (explanation != null && explanation.isNotEmpty) explanation,
      '${strings.suggestedAction}: $action',
      if (suggested != null) '-> $suggested',
    ];
    return parts.join('  ');
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: destructive ? AppColors.danger : AppColors.primaryDark,
        disabledBackgroundColor: const Color(0xFFE4E8EF),
        foregroundColor: Colors.white,
        disabledForegroundColor: const Color(0xFF8993A6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DialogError extends StatelessWidget {
  const _DialogError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: AppErrorView(message: message),
    );
  }
}

Future<void> _runDecision(
  BuildContext context,
  WidgetRef ref,
  Future<DecisionResult> future,
  VoidCallback onFinished,
) async {
  try {
    await future;
    final pending = ref
        .read(dataPreviewControllerProvider)
        .valueOrNull
        ?.pendingCount;
    if (pending == 0 && context.mounted) onFinished();
  } catch (error) {
    if (!context.mounted) return;
    showAppSnackBar(context, message: error.toString(), isError: true);
  }
}

IconData _severityIcon(String severity) {
  return severity == 'high'
      ? Icons.warning_amber_rounded
      : Icons.report_problem_outlined;
}

Color _severityColor(String severity) {
  return severity == 'high' ? AppColors.danger : const Color(0xFF2457D6);
}

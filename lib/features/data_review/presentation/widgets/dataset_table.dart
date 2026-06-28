import 'package:flutter/material.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../../core/presentation/responsive.dart';
import '../../data/models/dataset_models.dart';
import '../data_review_strings.dart';

class DatasetTable extends StatefulWidget {
  const DatasetTable({
    super.key,
    required this.preview,
    this.sheets = const [],
    this.isLoading = false,
    this.onSheetChanged,
    this.onPageChanged,
  });

  final DatasetPreview preview;
  final List<DatasetSheetSummary> sheets;
  final bool isLoading;
  final ValueChanged<String>? onSheetChanged;
  final ValueChanged<int>? onPageChanged;

  @override
  State<DatasetTable> createState() => _DatasetTableState();
}

class _DatasetTableState extends State<DatasetTable> {
  final _horizontalController = ScrollController();
  final _verticalController = ScrollController();

  @override
  void didUpdateWidget(covariant DatasetTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.preview.page != widget.preview.page ||
        oldWidget.preview.sheetName != widget.preview.sheetName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_verticalController.hasClients) {
          _verticalController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final columns = widget.preview.columns;
    final tableWidth = 92.0 + (columns.length * 184.0);

    return AppSurface(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _PreviewToolbar(
            preview: widget.preview,
            sheets: widget.sheets,
            isLoading: widget.isLoading,
            onSheetChanged: widget.onSheetChanged,
            onPageChanged: widget.onPageChanged,
          ),
          const Divider(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = tableWidth < constraints.maxWidth
                    ? constraints.maxWidth
                    : tableWidth;
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Scrollbar(
                        controller: _verticalController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _verticalController,
                          padding: const EdgeInsets.only(right: 10),
                          child: Scrollbar(
                            controller: _horizontalController,
                            thumbVisibility: true,
                            notificationPredicate: (notification) =>
                                notification.metrics.axis == Axis.horizontal,
                            child: SingleChildScrollView(
                              controller: _horizontalController,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(bottom: 12),
                              child: SizedBox(
                                width: width,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _TableRowShell(
                                      isHeader: true,
                                      children: [
                                        _TableCellText(
                                          context.drStrings.row,
                                          isHeader: true,
                                        ),
                                        for (final column in columns)
                                          _TableCellText(
                                            column.name,
                                            isHeader: true,
                                          ),
                                      ],
                                    ),
                                    if (widget.preview.rows.isEmpty)
                                      SizedBox(
                                        height: 240,
                                        child: Center(
                                          child: Text(context.drStrings.noRows),
                                        ),
                                      )
                                    else
                                      for (final row in widget.preview.rows)
                                        _PreviewDataRow(
                                          row: row,
                                          columns: columns,
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.isLoading)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.white.withValues(alpha: 0.56),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.preview,
    required this.sheets,
    required this.isLoading,
    this.onSheetChanged,
    this.onPageChanged,
  });

  final DatasetPreview preview;
  final List<DatasetSheetSummary> sheets;
  final bool isLoading;
  final ValueChanged<String>? onSheetChanged;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive.of(context);
    final compact = responsive.useCompactLists;
    final sheetPicker = _SheetPicker(
      preview: preview,
      sheets: sheets,
      isLoading: isLoading,
      onSheetChanged: onSheetChanged,
    );
    final controls = _PageControls(
      preview: preview,
      isLoading: isLoading,
      onPageChanged: onPageChanged,
    );

    return Padding(
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [sheetPicker, const SizedBox(height: 12), controls],
            )
          : Row(
              children: [
                Expanded(child: sheetPicker),
                const SizedBox(width: 18),
                Flexible(child: controls),
              ],
            ),
    );
  }
}

class _SheetPicker extends StatelessWidget {
  const _SheetPicker({
    required this.preview,
    required this.sheets,
    required this.isLoading,
    this.onSheetChanged,
  });

  final DatasetPreview preview;
  final List<DatasetSheetSummary> sheets;
  final bool isLoading;
  final ValueChanged<String>? onSheetChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final sheetNames = [
      if (preview.sheetName.isNotEmpty) preview.sheetName,
      for (final sheet in sheets)
        if (sheet.sheetName.isNotEmpty && sheet.sheetName != preview.sheetName)
          sheet.sheetName,
    ];

    if (sheetNames.length <= 1 || onSheetChanged == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: AppInfoPill(
          icon: Icons.table_chart_rounded,
          label: preview.sheetName.isEmpty ? strings.sheet : preview.sheetName,
          color: const Color(0xFFE9F7F4),
          textColor: AppColors.primaryDark,
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: preview.sheetName,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: strings.sheet,
        prefixIcon: const Icon(Icons.table_chart_rounded),
      ),
      items: [
        for (final sheetName in sheetNames)
          DropdownMenuItem(value: sheetName, child: Text(sheetName)),
      ],
      onChanged: isLoading
          ? null
          : (value) {
              if (value == null || value == preview.sheetName) return;
              onSheetChanged?.call(value);
            },
    );
  }
}

class _PageControls extends StatelessWidget {
  const _PageControls({
    required this.preview,
    required this.isLoading,
    this.onPageChanged,
  });

  final DatasetPreview preview;
  final bool isLoading;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.drStrings;
    final totalPages = _totalPages(preview);
    final currentPage = _clampPage(preview.page, totalPages);
    final firstRow = preview.totalRows == 0
        ? 0
        : ((currentPage - 1) * preview.pageSize) + 1;
    final lastRow = preview.totalRows == 0
        ? 0
        : _min(currentPage * preview.pageSize, preview.totalRows);
    final canGoBack = currentPage > 1 && !isLoading && onPageChanged != null;
    final canGoForward =
        currentPage < totalPages && !isLoading && onPageChanged != null;

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        AppInfoPill(
          label: strings.rowsShown(firstRow, lastRow, preview.totalRows),
          color: const Color(0xFFEAF2FF),
          textColor: AppColors.info,
        ),
        Text(
          strings.pageOf(currentPage, totalPages),
          style: const TextStyle(
            color: AppColors.mutedText,
            fontWeight: FontWeight.w800,
          ),
        ),
        _PageIconButton(
          tooltip: strings.firstPage,
          icon: Icons.first_page_rounded,
          onPressed: canGoBack ? () => onPageChanged?.call(1) : null,
        ),
        _PageIconButton(
          tooltip: strings.previousPage,
          icon: Icons.chevron_left_rounded,
          onPressed: canGoBack
              ? () => onPageChanged?.call(currentPage - 1)
              : null,
        ),
        _PageIconButton(
          tooltip: strings.nextPage,
          icon: Icons.chevron_right_rounded,
          onPressed: canGoForward
              ? () => onPageChanged?.call(currentPage + 1)
              : null,
        ),
        _PageIconButton(
          tooltip: strings.lastPage,
          icon: Icons.last_page_rounded,
          onPressed: canGoForward
              ? () => onPageChanged?.call(totalPages)
              : null,
        ),
      ],
    );
  }
}

class _PageIconButton extends StatelessWidget {
  const _PageIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _PreviewDataRow extends StatelessWidget {
  const _PreviewDataRow({required this.row, required this.columns});

  final PreviewRow row;
  final List<PreviewColumn> columns;

  @override
  Widget build(BuildContext context) {
    return _TableRowShell(
      children: [
        _TableCellText(row.sourceRowNumber.toString()),
        for (final column in columns)
          _TableCellText(
            _formatValue(row.values[column.name]),
            status: row.cellStatus[column.name],
          ),
      ],
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return '';
    if (value is String && value.isEmpty) return '';
    return value.toString();
  }
}

class _TableRowShell extends StatelessWidget {
  const _TableRowShell({required this.children, this.isHeader = false});

  final List<Widget> children;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: isHeader ? 48 : 56),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isHeader ? AppColors.surfaceAlt : Colors.white,
            borderRadius: isHeader
                ? BorderRadius.circular(AppRadii.small)
                : null,
            border: isHeader
                ? null
                : const Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 92, child: children.first),
              for (final child in children.skip(1))
                SizedBox(width: 184, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableCellText extends StatelessWidget {
  const _TableCellText(this.text, {this.isHeader = false, this.status});

  final String text;
  final bool isHeader;
  final CellStatus? status;

  @override
  Widget build(BuildContext context) {
    final hasIssue = status?.hasIssue ?? false;
    final isHigh = status?.severity == 'high';
    final color = hasIssue
        ? (isHigh ? AppColors.danger : AppColors.warning)
        : AppColors.mutedText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SelectableText(
          text.isEmpty ? ' ' : text,
          style: TextStyle(
            color: isHeader ? AppColors.text : color,
            fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 0,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

int _totalPages(DatasetPreview preview) {
  if (preview.totalRows <= 0 || preview.pageSize <= 0) return 1;
  final total = (preview.totalRows + preview.pageSize - 1) ~/ preview.pageSize;
  return total < 1 ? 1 : total;
}

int _clampPage(int page, int totalPages) {
  if (page < 1) return 1;
  if (page > totalPages) return totalPages;
  return page;
}

int _min(int a, int b) => a < b ? a : b;

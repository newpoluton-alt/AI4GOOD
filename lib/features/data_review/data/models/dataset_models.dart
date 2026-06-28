class DatasetSheetSummary {
  const DatasetSheetSummary({
    required this.sheetName,
    required this.rowCount,
    required this.columnCount,
    required this.columns,
  });

  factory DatasetSheetSummary.fromJson(Map<String, dynamic> json) {
    return DatasetSheetSummary(
      sheetName: _string(json['sheet_name']),
      rowCount: _int(json['row_count']),
      columnCount: _int(json['column_count']),
      columns: _stringList(json['columns']),
    );
  }

  final String sheetName;
  final int rowCount;
  final int columnCount;
  final List<String> columns;
}

class PreviewColumn {
  const PreviewColumn({required this.name, required this.type});

  factory PreviewColumn.fromJson(Map<String, dynamic> json) {
    return PreviewColumn(
      name: _string(json['name']),
      type: _string(json['type'], fallback: 'string'),
    );
  }

  final String name;
  final String type;
}

class CellStatus {
  const CellStatus({
    required this.hasIssue,
    required this.severity,
    required this.issueIds,
  });

  factory CellStatus.fromJson(Map<String, dynamic> json) {
    return CellStatus(
      hasIssue: json['has_issue'] == true,
      severity: _string(json['severity'], fallback: 'medium'),
      issueIds: _stringList(json['issue_ids']),
    );
  }

  final bool hasIssue;
  final String severity;
  final List<String> issueIds;
}

class PreviewRow {
  const PreviewRow({
    required this.rowUid,
    required this.sourceRowNumber,
    required this.values,
    required this.cellStatus,
  });

  factory PreviewRow.fromJson(Map<String, dynamic> json) {
    final rawStatuses = (json['cell_status'] as Map?) ?? {};
    return PreviewRow(
      rowUid: _string(json['row_uid']),
      sourceRowNumber: _int(json['source_row_number']),
      values: (json['values'] as Map?)?.cast<String, dynamic>() ?? {},
      cellStatus: rawStatuses.map(
        (key, value) => MapEntry(
          key.toString(),
          CellStatus.fromJson((value as Map).cast<String, dynamic>()),
        ),
      ),
    );
  }

  final String rowUid;
  final int sourceRowNumber;
  final Map<String, dynamic> values;
  final Map<String, CellStatus> cellStatus;
}

class DatasetPreview {
  const DatasetPreview({
    required this.datasetId,
    required this.sheetName,
    required this.page,
    required this.pageSize,
    required this.totalRows,
    required this.columns,
    required this.rows,
  });

  factory DatasetPreview.fromJson(Map<String, dynamic> json) {
    return DatasetPreview(
      datasetId: _string(json['dataset_id']),
      sheetName: _string(json['sheet_name']),
      page: _int(json['page'], fallback: 1),
      pageSize: _int(json['page_size'], fallback: 50),
      totalRows: _int(json['total_rows']),
      columns: _mapList(
        json['columns'],
      ).map(PreviewColumn.fromJson).toList(growable: false),
      rows: _mapList(json['rows']).map(PreviewRow.fromJson).toList(),
    );
  }

  final String datasetId;
  final String sheetName;
  final int page;
  final int pageSize;
  final int totalRows;
  final List<PreviewColumn> columns;
  final List<PreviewRow> rows;
}

class UploadDatasetResult {
  const UploadDatasetResult({
    required this.datasetId,
    required this.reviewSessionId,
    required this.originalFilename,
    required this.status,
    required this.sheets,
    required this.preview,
  });

  factory UploadDatasetResult.fromJson(Map<String, dynamic> json) {
    return UploadDatasetResult(
      datasetId: _string(json['dataset_id']),
      reviewSessionId: _string(json['review_session_id']),
      originalFilename: _string(json['original_filename']),
      status: _string(json['status']),
      sheets: _mapList(
        json['sheets'],
      ).map(DatasetSheetSummary.fromJson).toList(growable: false),
      preview: DatasetPreview.fromJson(
        (json['preview'] as Map).cast<String, dynamic>(),
      ),
    );
  }

  final String datasetId;
  final String reviewSessionId;
  final String originalFilename;
  final String status;
  final List<DatasetSheetSummary> sheets;
  final DatasetPreview preview;
}

class DatasetDetail {
  const DatasetDetail({
    required this.datasetId,
    required this.originalFilename,
    required this.projectId,
    required this.status,
    required this.sheetCount,
    required this.rowCount,
    required this.columnCount,
    required this.language,
    required this.sheets,
    required this.processedExportId,
  });

  factory DatasetDetail.fromJson(Map<String, dynamic> json) {
    return DatasetDetail(
      datasetId: _string(json['dataset_id']),
      originalFilename: _string(json['original_filename']),
      projectId: _string(json['project_id']),
      status: _string(json['status']),
      sheetCount: _int(json['sheet_count']),
      rowCount: _int(json['row_count']),
      columnCount: _int(json['column_count']),
      language: _string(json['language'], fallback: 'fr'),
      sheets: _mapList(
        json['sheets'],
      ).map(DatasetSheetSummary.fromJson).toList(growable: false),
      processedExportId: json['processed_export_id']?.toString(),
    );
  }

  final String datasetId;
  final String originalFilename;
  final String projectId;
  final String status;
  final int sheetCount;
  final int rowCount;
  final int columnCount;
  final String language;
  final List<DatasetSheetSummary> sheets;
  final String? processedExportId;
}

class MyDataItem {
  const MyDataItem({
    required this.number,
    required this.datasetId,
    required this.originalFilename,
    required this.projectId,
    required this.status,
    required this.uploadDate,
    required this.rowCount,
    required this.sheetCount,
    required this.processedExportId,
  });

  factory MyDataItem.fromJson(Map<String, dynamic> json) {
    return MyDataItem(
      number: _int(json['number']),
      datasetId: _string(json['dataset_id']),
      originalFilename: _string(json['original_filename']),
      projectId: _string(json['project_id']),
      status: _string(json['status']),
      uploadDate:
          DateTime.tryParse(_string(json['upload_date'])) ?? DateTime.now(),
      rowCount: json['row_count'] == null ? null : _int(json['row_count']),
      sheetCount: _int(json['sheet_count']),
      processedExportId: json['processed_export_id']?.toString(),
    );
  }

  final int number;
  final String datasetId;
  final String originalFilename;
  final String projectId;
  final String status;
  final DateTime uploadDate;
  final int? rowCount;
  final int sheetCount;
  final String? processedExportId;
}

class DownloadLink {
  const DownloadLink({
    required this.downloadUrl,
    required this.filename,
    required this.expiresInSeconds,
  });

  factory DownloadLink.fromJson(Map<String, dynamic> json) {
    return DownloadLink(
      downloadUrl: _string(json['download_url']),
      filename: _string(json['filename']),
      expiresInSeconds: _int(json['expires_in_seconds']),
    );
  }

  final String downloadUrl;
  final String filename;
  final int expiresInSeconds;
}

class DatasetPreviewBundle {
  const DatasetPreviewBundle({
    required this.datasetId,
    this.reviewSessionId,
    required this.sheets,
    required this.preview,
  });

  final String datasetId;
  final String? reviewSessionId;
  final List<DatasetSheetSummary> sheets;
  final DatasetPreview preview;
}

String _string(Object? value, {String fallback = ''}) {
  final text = value?.toString();
  return text == null || text.isEmpty ? fallback : text;
}

int _int(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map((item) => item.toString()).toList(growable: false);
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.cast<String, dynamic>())
      .toList(growable: false);
}

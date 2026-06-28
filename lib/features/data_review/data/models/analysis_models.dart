class EligibleDatasetItem {
  const EligibleDatasetItem({
    required this.datasetId,
    required this.originalFilename,
    required this.projectId,
    required this.status,
    required this.rowCount,
    required this.finalized,
  });

  factory EligibleDatasetItem.fromJson(Map<String, dynamic> json) {
    return EligibleDatasetItem(
      datasetId: _string(json['dataset_id']),
      originalFilename: _string(json['original_filename']),
      projectId: _string(json['project_id']),
      status: _string(json['status']),
      rowCount: _int(json['row_count']),
      finalized: json['finalized'] == true,
    );
  }

  final String datasetId;
  final String originalFilename;
  final String projectId;
  final String status;
  final int rowCount;
  final bool finalized;
}

class AnalysisJobResult {
  const AnalysisJobResult({required this.analysisJobId, required this.status});

  factory AnalysisJobResult.fromJson(Map<String, dynamic> json) {
    return AnalysisJobResult(
      analysisJobId: _string(json['analysis_job_id']),
      status: _string(json['status']),
    );
  }

  final String analysisJobId;
  final String status;
}

class AnalysisJobStatus {
  const AnalysisJobStatus({
    required this.analysisJobId,
    required this.status,
    required this.progress,
    required this.language,
    required this.reportExportId,
    required this.errorMessage,
    required this.createdAt,
    required this.completedAt,
  });

  factory AnalysisJobStatus.fromJson(Map<String, dynamic> json) {
    return AnalysisJobStatus(
      analysisJobId: _string(json['analysis_job_id']),
      status: _string(json['status']),
      progress: _int(json['progress']),
      language: _string(json['language']),
      reportExportId: json['report_export_id']?.toString(),
      errorMessage: json['error_message']?.toString(),
      createdAt:
          DateTime.tryParse(_string(json['created_at'])) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.tryParse(_string(json['completed_at'])),
    );
  }

  final String analysisJobId;
  final String status;
  final int progress;
  final String language;
  final String? reportExportId;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
}

class AnalysisReport {
  const AnalysisReport({
    required this.analysisJobId,
    required this.status,
    required this.language,
    required this.reportMarkdown,
    required this.reportHtml,
    required this.anonymizationSummary,
    required this.analysisSummary,
  });

  factory AnalysisReport.fromJson(Map<String, dynamic> json) {
    return AnalysisReport(
      analysisJobId: _string(json['analysis_job_id']),
      status: _string(json['status']),
      language: _string(json['language']),
      reportMarkdown: _string(json['report_markdown']),
      reportHtml: _string(json['report_html']),
      anonymizationSummary:
          (json['anonymization_summary'] as Map?)?.cast<String, dynamic>() ??
          {},
      analysisSummary:
          (json['analysis_summary'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  final String analysisJobId;
  final String status;
  final String language;
  final String reportMarkdown;
  final String reportHtml;
  final Map<String, dynamic> anonymizationSummary;
  final Map<String, dynamic> analysisSummary;
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

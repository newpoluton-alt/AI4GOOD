class ReviewRunResult {
  const ReviewRunResult({
    required this.reviewSessionId,
    required this.status,
    required this.totalIssueCount,
    required this.issueGroupCount,
    required this.pendingCount,
    required this.groups,
  });

  factory ReviewRunResult.fromJson(Map<String, dynamic> json) {
    return ReviewRunResult(
      reviewSessionId: _string(json['review_session_id']),
      status: _string(json['status']),
      totalIssueCount: _int(json['total_issue_count']),
      issueGroupCount: _int(json['issue_group_count']),
      pendingCount: _int(json['pending_count']),
      groups: _mapList(
        json['groups'],
      ).map(IssueGroupSummary.fromJson).toList(growable: false),
    );
  }

  final String reviewSessionId;
  final String status;
  final int totalIssueCount;
  final int issueGroupCount;
  final int pendingCount;
  final List<IssueGroupSummary> groups;
}

class IssueGroupSummary {
  const IssueGroupSummary({
    required this.groupId,
    required this.ruleCode,
    required this.title,
    required this.severity,
    required this.issueCount,
    required this.pendingCount,
    required this.acceptedCount,
    required this.declinedCount,
  });

  factory IssueGroupSummary.fromJson(Map<String, dynamic> json) {
    return IssueGroupSummary(
      groupId: _string(json['group_id']),
      ruleCode: _string(json['rule_code']),
      title: _string(json['title']),
      severity: _string(json['severity'], fallback: 'medium'),
      issueCount: _int(json['issue_count']),
      pendingCount: _int(json['pending_count']),
      acceptedCount: _int(json['accepted_count']),
      declinedCount: _int(json['declined_count']),
    );
  }

  IssueGroupSummary copyWith({
    int? pendingCount,
    int? acceptedCount,
    int? declinedCount,
  }) {
    return IssueGroupSummary(
      groupId: groupId,
      ruleCode: ruleCode,
      title: title,
      severity: severity,
      issueCount: issueCount,
      pendingCount: pendingCount ?? this.pendingCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      declinedCount: declinedCount ?? this.declinedCount,
    );
  }

  final String groupId;
  final String ruleCode;
  final String title;
  final String severity;
  final int issueCount;
  final int pendingCount;
  final int acceptedCount;
  final int declinedCount;
}

class IssueListResult {
  const IssueListResult({
    required this.groupId,
    required this.total,
    required this.issues,
  });

  factory IssueListResult.fromJson(Map<String, dynamic> json) {
    return IssueListResult(
      groupId: _string(json['group_id']),
      total: _int(json['total']),
      issues: _mapList(
        json['issues'],
      ).map(IssueItem.fromJson).toList(growable: false),
    );
  }

  final String groupId;
  final int total;
  final List<IssueItem> issues;
}

class IssueItem {
  const IssueItem({
    required this.issueId,
    required this.groupId,
    required this.ruleCode,
    required this.severity,
    required this.sheetName,
    required this.rowUid,
    required this.sourceRowNumber,
    required this.columnName,
    required this.cellUid,
    required this.oldValue,
    required this.suggestedValue,
    required this.operationType,
    required this.operationPayload,
    required this.explanation,
    required this.status,
  });

  factory IssueItem.fromJson(Map<String, dynamic> json) {
    return IssueItem(
      issueId: _string(json['issue_id']),
      groupId: _string(json['group_id']),
      ruleCode: _string(json['rule_code']),
      severity: _string(json['severity'], fallback: 'medium'),
      sheetName: _string(json['sheet_name']),
      rowUid: json['row_uid']?.toString(),
      sourceRowNumber: json['source_row_number'] == null
          ? null
          : _int(json['source_row_number']),
      columnName: json['column_name']?.toString(),
      cellUid: json['cell_uid']?.toString(),
      oldValue: json['old_value'],
      suggestedValue: json['suggested_value'],
      operationType: _string(json['operation_type']),
      operationPayload:
          (json['operation_payload'] as Map?)?.cast<String, dynamic>() ?? {},
      explanation: json['explanation']?.toString(),
      status: _string(json['status'], fallback: 'pending'),
    );
  }

  IssueItem copyWith({String? status}) {
    return IssueItem(
      issueId: issueId,
      groupId: groupId,
      ruleCode: ruleCode,
      severity: severity,
      sheetName: sheetName,
      rowUid: rowUid,
      sourceRowNumber: sourceRowNumber,
      columnName: columnName,
      cellUid: cellUid,
      oldValue: oldValue,
      suggestedValue: suggestedValue,
      operationType: operationType,
      operationPayload: operationPayload,
      explanation: explanation,
      status: status ?? this.status,
    );
  }

  final String issueId;
  final String groupId;
  final String ruleCode;
  final String severity;
  final String sheetName;
  final String? rowUid;
  final int? sourceRowNumber;
  final String? columnName;
  final String? cellUid;
  final dynamic oldValue;
  final dynamic suggestedValue;
  final String operationType;
  final Map<String, dynamic> operationPayload;
  final String? explanation;
  final String status;
}

class DecisionResult {
  const DecisionResult({
    required this.issueId,
    required this.groupId,
    required this.reviewSessionId,
    required this.status,
    required this.patchSetId,
    required this.affected,
    required this.pendingCount,
  });

  factory DecisionResult.fromJson(Map<String, dynamic> json) {
    return DecisionResult(
      issueId: json['issue_id']?.toString(),
      groupId: json['group_id']?.toString(),
      reviewSessionId: _string(json['review_session_id']),
      status: _string(json['status']),
      patchSetId: json['patch_set_id']?.toString(),
      affected: _int(json['affected']),
      pendingCount: _int(json['pending_count']),
    );
  }

  final String? issueId;
  final String? groupId;
  final String reviewSessionId;
  final String status;
  final String? patchSetId;
  final int affected;
  final int pendingCount;
}

class FinalizeResult {
  const FinalizeResult({
    required this.exportId,
    required this.datasetId,
    required this.reviewSessionId,
    required this.status,
    required this.processedFilename,
    required this.downloadUrl,
    required this.expiresInSeconds,
    required this.summary,
  });

  factory FinalizeResult.fromJson(Map<String, dynamic> json) {
    return FinalizeResult(
      exportId: _string(json['export_id']),
      datasetId: _string(json['dataset_id']),
      reviewSessionId: _string(json['review_session_id']),
      status: _string(json['status']),
      processedFilename: _string(json['processed_filename']),
      downloadUrl: _string(json['download_url']),
      expiresInSeconds: _int(json['expires_in_seconds']),
      summary: (json['summary'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  final String exportId;
  final String datasetId;
  final String reviewSessionId;
  final String status;
  final String processedFilename;
  final String downloadUrl;
  final int expiresInSeconds;
  final Map<String, dynamic> summary;
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

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => item.cast<String, dynamic>())
      .toList(growable: false);
}

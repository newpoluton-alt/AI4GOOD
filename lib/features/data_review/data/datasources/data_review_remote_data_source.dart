import 'dart:typed_data';

import '../../../../core/network/api_client.dart';
import '../models/analysis_models.dart';
import '../models/dataset_models.dart';
import '../models/review_models.dart';

abstract class DataReviewRemoteDataSource {
  Future<UploadDatasetResult> uploadDataset({
    required List<int> bytes,
    required String filename,
    required String projectId,
    String? module,
    required String language,
    String? selectedSheet,
  });

  Future<DatasetPreview> getDatasetPreview(
    String datasetId, {
    String? sheet,
    int page = 1,
    int pageSize = 50,
  });

  Future<void> saveDataset(String datasetId);
  Future<DatasetDetail> getDatasetDetail(String datasetId);
  Future<DownloadLink> getOriginalDownload(String datasetId);
  Future<DownloadLink> getProcessedDownload(String datasetId);
  Future<int> deleteDataset(String datasetId);
  Future<List<MyDataItem>> getMyData();
  Future<int> deleteAllMyData();
  Future<ReviewRunResult> runReview(
    String datasetId, {
    String? sheetName,
    required String language,
    required List<String> ruleSets,
  });
  Future<List<IssueGroupSummary>> getIssueGroups(String reviewSessionId);
  Future<IssueListResult> getGroupIssues(
    String reviewSessionId,
    String groupId, {
    int page = 1,
    int pageSize = 100,
  });
  Future<DecisionResult> acceptIssue(String reviewSessionId, String issueId);
  Future<DecisionResult> declineIssue(String reviewSessionId, String issueId);
  Future<DecisionResult> acceptIssueGroup(
    String reviewSessionId,
    String groupId,
  );
  Future<DecisionResult> declineIssueGroup(
    String reviewSessionId,
    String groupId,
  );
  Future<DecisionResult> declineAllPending(String reviewSessionId);
  Future<DecisionResult> undoPatchSet(
    String reviewSessionId,
    String patchSetId,
  );
  Future<FinalizeResult> finalizeReview(
    String reviewSessionId, {
    bool force = false,
    bool includeAuditSheet = true,
    required String language,
  });
  Future<List<EligibleDatasetItem>> getEligibleDatasets();
  Future<AnalysisJobResult> createAnalysisJob({
    required List<String> datasetIds,
    required String prompt,
    required String language,
    bool includeCharts = true,
  });
  Future<AnalysisJobStatus> getAnalysisJobStatus(String jobId);
  Future<AnalysisReport> getAnalysisReport(String jobId);
  Future<Uint8List> downloadReportPdf(String jobId);
}

class DataReviewRemoteDataSourceImpl implements DataReviewRemoteDataSource {
  const DataReviewRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UploadDatasetResult> uploadDataset({
    required List<int> bytes,
    required String filename,
    required String projectId,
    String? module,
    required String language,
    String? selectedSheet,
  }) async {
    final json = await _apiClient.multipartUpload(
      path: '/v1/datasets/upload',
      bytes: bytes,
      filename: filename,
      fields: {
        'project_id': projectId,
        'language': language,
        if (module != null && module.isNotEmpty) 'module': module,
        if (selectedSheet != null && selectedSheet.isNotEmpty)
          'selected_sheet': selectedSheet,
      },
    );
    return UploadDatasetResult.fromJson(json);
  }

  @override
  Future<DatasetPreview> getDatasetPreview(
    String datasetId, {
    String? sheet,
    int page = 1,
    int pageSize = 50,
  }) async {
    final json =
        await _apiClient.getJson(
              '/v1/datasets/$datasetId/preview',
              query: {
                if (sheet != null && sheet.isNotEmpty) 'sheet': sheet,
                'page': page,
                'page_size': pageSize,
              },
            )
            as Map<String, dynamic>;
    return DatasetPreview.fromJson(json);
  }

  @override
  Future<void> saveDataset(String datasetId) async {
    await _apiClient.postJson('/v1/datasets/$datasetId/save');
  }

  @override
  Future<DatasetDetail> getDatasetDetail(String datasetId) async {
    final json =
        await _apiClient.getJson('/v1/datasets/$datasetId')
            as Map<String, dynamic>;
    return DatasetDetail.fromJson(json);
  }

  @override
  Future<DownloadLink> getOriginalDownload(String datasetId) async {
    final json =
        await _apiClient.getJson('/v1/datasets/$datasetId/download/original')
            as Map<String, dynamic>;
    return DownloadLink.fromJson(json);
  }

  @override
  Future<DownloadLink> getProcessedDownload(String datasetId) async {
    final json =
        await _apiClient.getJson('/v1/datasets/$datasetId/download/processed')
            as Map<String, dynamic>;
    return DownloadLink.fromJson(json);
  }

  @override
  Future<int> deleteDataset(String datasetId) async {
    final json =
        await _apiClient.deleteJson('/v1/datasets/$datasetId')
            as Map<String, dynamic>;
    return _int(json['deleted']);
  }

  @override
  Future<List<MyDataItem>> getMyData() async {
    final json =
        await _apiClient.getJson('/v1/my-data') as Map<String, dynamic>;
    final items = json['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => MyDataItem.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<int> deleteAllMyData() async {
    final json =
        await _apiClient.deleteJson('/v1/my-data') as Map<String, dynamic>;
    return _int(json['deleted']);
  }

  @override
  Future<ReviewRunResult> runReview(
    String datasetId, {
    String? sheetName,
    required String language,
    required List<String> ruleSets,
  }) async {
    final json =
        await _apiClient.postJson(
              '/v1/datasets/$datasetId/review/run',
              body: {
                if (sheetName != null && sheetName.isNotEmpty)
                  'sheet_name': sheetName,
                'language': language,
                'rule_sets': ruleSets,
                'use_bedrock_explanations': false,
              },
            )
            as Map<String, dynamic>;
    return ReviewRunResult.fromJson(json);
  }

  @override
  Future<List<IssueGroupSummary>> getIssueGroups(String reviewSessionId) async {
    final json = await _apiClient.getJson(
      '/v1/review-sessions/$reviewSessionId/issue-groups',
    );
    final items = json as List? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => IssueGroupSummary.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  @override
  Future<IssueListResult> getGroupIssues(
    String reviewSessionId,
    String groupId, {
    int page = 1,
    int pageSize = 100,
  }) async {
    final json =
        await _apiClient.getJson(
              '/v1/review-sessions/$reviewSessionId/issue-groups/$groupId/issues',
              query: {'page': page, 'page_size': pageSize},
            )
            as Map<String, dynamic>;
    return IssueListResult.fromJson(json);
  }

  @override
  Future<DecisionResult> acceptIssue(
    String reviewSessionId,
    String issueId,
  ) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/issues/$issueId/accept',
            )
            as Map<String, dynamic>;
    return DecisionResult.fromJson(json);
  }

  @override
  Future<DecisionResult> declineIssue(
    String reviewSessionId,
    String issueId,
  ) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/issues/$issueId/decline',
            )
            as Map<String, dynamic>;
    return DecisionResult.fromJson(json);
  }

  @override
  Future<DecisionResult> acceptIssueGroup(
    String reviewSessionId,
    String groupId,
  ) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/issue-groups/$groupId/accept-all',
            )
            as Map<String, dynamic>;
    return DecisionResult.fromJson(json);
  }

  @override
  Future<DecisionResult> declineIssueGroup(
    String reviewSessionId,
    String groupId,
  ) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/issue-groups/$groupId/decline-all',
            )
            as Map<String, dynamic>;
    return DecisionResult.fromJson(json);
  }

  @override
  Future<DecisionResult> declineAllPending(String reviewSessionId) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/decline-all-pending',
            )
            as Map<String, dynamic>;
    return DecisionResult.fromJson(json);
  }

  @override
  Future<DecisionResult> undoPatchSet(
    String reviewSessionId,
    String patchSetId,
  ) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/patch-sets/$patchSetId/undo',
            )
            as Map<String, dynamic>;
    return DecisionResult.fromJson(json);
  }

  @override
  Future<FinalizeResult> finalizeReview(
    String reviewSessionId, {
    bool force = false,
    bool includeAuditSheet = true,
    required String language,
  }) async {
    final json =
        await _apiClient.postJson(
              '/v1/review-sessions/$reviewSessionId/finalize',
              body: {
                'force': force,
                'include_audit_sheet': includeAuditSheet,
                'language': language,
              },
            )
            as Map<String, dynamic>;
    return FinalizeResult.fromJson(json);
  }

  @override
  Future<List<EligibleDatasetItem>> getEligibleDatasets() async {
    final json =
        await _apiClient.getJson('/v1/analysis/eligible-datasets')
            as Map<String, dynamic>;
    final items = json['items'] as List? ?? const [];
    return items
        .whereType<Map>()
        .map(
          (item) => EligibleDatasetItem.fromJson(item.cast<String, dynamic>()),
        )
        .toList(growable: false);
  }

  @override
  Future<AnalysisJobResult> createAnalysisJob({
    required List<String> datasetIds,
    required String prompt,
    required String language,
    bool includeCharts = true,
  }) async {
    final json =
        await _apiClient.postJson(
              '/v1/analysis/jobs',
              body: {
                'dataset_ids': datasetIds,
                'prompt': prompt,
                'language': language,
                'include_charts': includeCharts,
              },
            )
            as Map<String, dynamic>;
    return AnalysisJobResult.fromJson(json);
  }

  @override
  Future<AnalysisJobStatus> getAnalysisJobStatus(String jobId) async {
    final json =
        await _apiClient.getJson('/v1/analysis/jobs/$jobId')
            as Map<String, dynamic>;
    return AnalysisJobStatus.fromJson(json);
  }

  @override
  Future<AnalysisReport> getAnalysisReport(String jobId) async {
    final json =
        await _apiClient.getJson('/v1/analysis/jobs/$jobId/report')
            as Map<String, dynamic>;
    return AnalysisReport.fromJson(json);
  }

  @override
  Future<Uint8List> downloadReportPdf(String jobId) {
    return _apiClient.getBytes('/v1/analysis/jobs/$jobId/report.pdf');
  }
}

int _int(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

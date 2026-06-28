import 'dart:typed_data';

import '../../data/models/analysis_models.dart';
import '../../data/models/dataset_models.dart';
import '../../data/models/review_models.dart';

abstract class DataReviewRepository {
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
    List<String> ruleSets = const ['generic', 'community_agent'],
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

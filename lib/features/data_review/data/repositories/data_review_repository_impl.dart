import 'dart:typed_data';

import '../../domain/repositories/data_review_repository.dart';
import '../datasources/data_review_remote_data_source.dart';
import '../models/analysis_models.dart';
import '../models/dataset_models.dart';
import '../models/review_models.dart';

class DataReviewRepositoryImpl implements DataReviewRepository {
  const DataReviewRepositoryImpl(this._remoteDataSource);

  final DataReviewRemoteDataSource _remoteDataSource;

  @override
  Future<UploadDatasetResult> uploadDataset({
    required List<int> bytes,
    required String filename,
    required String projectId,
    String? module,
    required String language,
    String? selectedSheet,
  }) {
    return _remoteDataSource.uploadDataset(
      bytes: bytes,
      filename: filename,
      projectId: projectId,
      module: module,
      language: language,
      selectedSheet: selectedSheet,
    );
  }

  @override
  Future<DatasetPreview> getDatasetPreview(
    String datasetId, {
    String? sheet,
    int page = 1,
    int pageSize = 50,
  }) {
    return _remoteDataSource.getDatasetPreview(
      datasetId,
      sheet: sheet,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> saveDataset(String datasetId) {
    return _remoteDataSource.saveDataset(datasetId);
  }

  @override
  Future<DatasetDetail> getDatasetDetail(String datasetId) {
    return _remoteDataSource.getDatasetDetail(datasetId);
  }

  @override
  Future<DownloadLink> getOriginalDownload(String datasetId) {
    return _remoteDataSource.getOriginalDownload(datasetId);
  }

  @override
  Future<DownloadLink> getProcessedDownload(String datasetId) {
    return _remoteDataSource.getProcessedDownload(datasetId);
  }

  @override
  Future<int> deleteDataset(String datasetId) {
    return _remoteDataSource.deleteDataset(datasetId);
  }

  @override
  Future<List<MyDataItem>> getMyData() {
    return _remoteDataSource.getMyData();
  }

  @override
  Future<int> deleteAllMyData() {
    return _remoteDataSource.deleteAllMyData();
  }

  @override
  Future<ReviewRunResult> runReview(
    String datasetId, {
    String? sheetName,
    required String language,
    List<String> ruleSets = const ['generic', 'community_agent'],
  }) {
    return _remoteDataSource.runReview(
      datasetId,
      sheetName: sheetName,
      language: language,
      ruleSets: ruleSets,
    );
  }

  @override
  Future<List<IssueGroupSummary>> getIssueGroups(String reviewSessionId) {
    return _remoteDataSource.getIssueGroups(reviewSessionId);
  }

  @override
  Future<IssueListResult> getGroupIssues(
    String reviewSessionId,
    String groupId, {
    int page = 1,
    int pageSize = 100,
  }) {
    return _remoteDataSource.getGroupIssues(
      reviewSessionId,
      groupId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<DecisionResult> acceptIssue(String reviewSessionId, String issueId) {
    return _remoteDataSource.acceptIssue(reviewSessionId, issueId);
  }

  @override
  Future<DecisionResult> declineIssue(String reviewSessionId, String issueId) {
    return _remoteDataSource.declineIssue(reviewSessionId, issueId);
  }

  @override
  Future<DecisionResult> acceptIssueGroup(
    String reviewSessionId,
    String groupId,
  ) {
    return _remoteDataSource.acceptIssueGroup(reviewSessionId, groupId);
  }

  @override
  Future<DecisionResult> declineIssueGroup(
    String reviewSessionId,
    String groupId,
  ) {
    return _remoteDataSource.declineIssueGroup(reviewSessionId, groupId);
  }

  @override
  Future<DecisionResult> declineAllPending(String reviewSessionId) {
    return _remoteDataSource.declineAllPending(reviewSessionId);
  }

  @override
  Future<DecisionResult> undoPatchSet(
    String reviewSessionId,
    String patchSetId,
  ) {
    return _remoteDataSource.undoPatchSet(reviewSessionId, patchSetId);
  }

  @override
  Future<FinalizeResult> finalizeReview(
    String reviewSessionId, {
    bool force = false,
    bool includeAuditSheet = true,
    required String language,
  }) {
    return _remoteDataSource.finalizeReview(
      reviewSessionId,
      force: force,
      includeAuditSheet: includeAuditSheet,
      language: language,
    );
  }

  @override
  Future<List<EligibleDatasetItem>> getEligibleDatasets() {
    return _remoteDataSource.getEligibleDatasets();
  }

  @override
  Future<AnalysisJobResult> createAnalysisJob({
    required List<String> datasetIds,
    required String prompt,
    required String language,
    bool includeCharts = true,
  }) {
    return _remoteDataSource.createAnalysisJob(
      datasetIds: datasetIds,
      prompt: prompt,
      language: language,
      includeCharts: includeCharts,
    );
  }

  @override
  Future<AnalysisJobStatus> getAnalysisJobStatus(String jobId) {
    return _remoteDataSource.getAnalysisJobStatus(jobId);
  }

  @override
  Future<AnalysisReport> getAnalysisReport(String jobId) {
    return _remoteDataSource.getAnalysisReport(jobId);
  }

  @override
  Future<Uint8List> downloadReportPdf(String jobId) {
    return _remoteDataSource.downloadReportPdf(jobId);
  }
}

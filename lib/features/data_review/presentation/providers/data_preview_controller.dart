import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dataset_models.dart';
import '../../data/models/review_models.dart';
import '../../domain/repositories/data_review_repository.dart';
import 'data_review_providers.dart';

final dataPreviewControllerProvider =
    StateNotifierProvider.autoDispose<
      DataPreviewController,
      AsyncValue<DataPreviewState>
    >((ref) {
      return DataPreviewController(ref.watch(dataReviewRepositoryProvider));
    });

class DataPreviewState {
  const DataPreviewState({
    required this.datasetId,
    this.reviewSessionId,
    this.sheets = const [],
    this.preview,
    this.issueGroups = const [],
    this.issuesByGroup = const {},
    this.loadingGroupIds = const {},
    this.pendingCount = 0,
    this.totalIssueCount = 0,
    this.isActionRunning = false,
    this.isFinalizing = false,
    this.finalizeResult,
  });

  const DataPreviewState.empty() : this(datasetId: '');

  final String datasetId;
  final String? reviewSessionId;
  final List<DatasetSheetSummary> sheets;
  final DatasetPreview? preview;
  final List<IssueGroupSummary> issueGroups;
  final Map<String, List<IssueItem>> issuesByGroup;
  final Set<String> loadingGroupIds;
  final int pendingCount;
  final int totalIssueCount;
  final bool isActionRunning;
  final bool isFinalizing;
  final FinalizeResult? finalizeResult;

  int get acceptedCount =>
      issueGroups.fold(0, (total, group) => total + group.acceptedCount);
  int get declinedCount =>
      issueGroups.fold(0, (total, group) => total + group.declinedCount);

  DataPreviewState copyWith({
    String? datasetId,
    String? reviewSessionId,
    List<DatasetSheetSummary>? sheets,
    DatasetPreview? preview,
    List<IssueGroupSummary>? issueGroups,
    Map<String, List<IssueItem>>? issuesByGroup,
    Set<String>? loadingGroupIds,
    int? pendingCount,
    int? totalIssueCount,
    bool? isActionRunning,
    bool? isFinalizing,
    FinalizeResult? finalizeResult,
  }) {
    return DataPreviewState(
      datasetId: datasetId ?? this.datasetId,
      reviewSessionId: reviewSessionId ?? this.reviewSessionId,
      sheets: sheets ?? this.sheets,
      preview: preview ?? this.preview,
      issueGroups: issueGroups ?? this.issueGroups,
      issuesByGroup: issuesByGroup ?? this.issuesByGroup,
      loadingGroupIds: loadingGroupIds ?? this.loadingGroupIds,
      pendingCount: pendingCount ?? this.pendingCount,
      totalIssueCount: totalIssueCount ?? this.totalIssueCount,
      isActionRunning: isActionRunning ?? this.isActionRunning,
      isFinalizing: isFinalizing ?? this.isFinalizing,
      finalizeResult: finalizeResult ?? this.finalizeResult,
    );
  }
}

class DataPreviewController
    extends StateNotifier<AsyncValue<DataPreviewState>> {
  DataPreviewController(this._repository)
    : super(const AsyncData(DataPreviewState.empty()));

  final DataReviewRepository _repository;

  void setInitial({
    required String datasetId,
    required String? reviewSessionId,
    required List<DatasetSheetSummary> sheets,
    required DatasetPreview preview,
  }) {
    state = AsyncData(
      DataPreviewState(
        datasetId: datasetId,
        reviewSessionId: reviewSessionId,
        sheets: sheets,
        preview: preview,
      ),
    );
  }

  Future<void> loadPreview({String? sheet, int page = 1}) async {
    final current = state.valueOrNull;
    if (current == null || current.datasetId.isEmpty) return;
    state = AsyncData(current.copyWith(isActionRunning: true));
    try {
      final preview = await _repository.getDatasetPreview(
        current.datasetId,
        sheet: sheet ?? current.preview?.sheetName,
        page: page,
        pageSize: current.preview?.pageSize ?? 50,
      );
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          preview: preview,
          isActionRunning: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isActionRunning: false));
      rethrow;
    }
  }

  Future<ReviewRunResult> runReview({required String language}) async {
    final current = state.valueOrNull;
    if (current == null || current.datasetId.isEmpty) {
      throw StateError('No dataset is loaded.');
    }
    state = AsyncData(current.copyWith(isActionRunning: true));
    try {
      final result = await _repository.runReview(
        current.datasetId,
        sheetName: current.preview?.sheetName,
        language: language,
      );
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          reviewSessionId: result.reviewSessionId,
          issueGroups: result.groups,
          pendingCount: result.pendingCount,
          totalIssueCount: result.totalIssueCount,
          issuesByGroup: {},
          isActionRunning: false,
        ),
      );
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> loadGroupIssues(String groupId) async {
    final current = state.valueOrNull;
    final reviewSessionId = current?.reviewSessionId;
    if (current == null ||
        reviewSessionId == null ||
        current.issuesByGroup.containsKey(groupId) ||
        current.loadingGroupIds.contains(groupId)) {
      return;
    }

    state = AsyncData(
      current.copyWith(loadingGroupIds: {...current.loadingGroupIds, groupId}),
    );
    try {
      final result = await _repository.getGroupIssues(reviewSessionId, groupId);
      final latest = state.valueOrNull ?? current;
      final loading = {...latest.loadingGroupIds}..remove(groupId);
      state = AsyncData(
        latest.copyWith(
          issuesByGroup: {...latest.issuesByGroup, groupId: result.issues},
          loadingGroupIds: loading,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<DecisionResult> acceptIssue(String issueId) {
    return _applyDecision(
      () => _repository.acceptIssue(_requiredReviewSessionId(), issueId),
      issueId: issueId,
      status: 'accepted',
    );
  }

  Future<DecisionResult> declineIssue(String issueId) {
    return _applyDecision(
      () => _repository.declineIssue(_requiredReviewSessionId(), issueId),
      issueId: issueId,
      status: 'declined',
    );
  }

  Future<DecisionResult> acceptIssueGroup(String groupId) {
    return _applyDecision(
      () => _repository.acceptIssueGroup(_requiredReviewSessionId(), groupId),
      groupId: groupId,
      status: 'accepted',
    );
  }

  Future<DecisionResult> declineIssueGroup(String groupId) {
    return _applyDecision(
      () => _repository.declineIssueGroup(_requiredReviewSessionId(), groupId),
      groupId: groupId,
      status: 'declined',
    );
  }

  Future<DecisionResult> declineAllPending() {
    return _applyDecision(
      () => _repository.declineAllPending(_requiredReviewSessionId()),
      status: 'declined',
      allPending: true,
    );
  }

  Future<DecisionResult> _applyDecision(
    Future<DecisionResult> Function() action, {
    String? issueId,
    String? groupId,
    required String status,
    bool allPending = false,
  }) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('No preview state is loaded.');
    state = AsyncData(current.copyWith(isActionRunning: true));
    try {
      final result = await action();
      final latest = state.valueOrNull ?? current;
      final groups = await _safeLoadGroups(latest.reviewSessionId);
      state = AsyncData(
        latest.copyWith(
          issueGroups: groups ?? latest.issueGroups,
          issuesByGroup: _markIssues(
            latest.issuesByGroup,
            issueId: issueId,
            groupId: groupId,
            allPending: allPending,
            status: status,
          ),
          pendingCount: result.pendingCount,
          isActionRunning: false,
        ),
      );
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<FinalizeResult> finalizeReview({required String language}) async {
    final current = state.valueOrNull;
    if (current == null) throw StateError('No preview state is loaded.');
    final reviewSessionId = _requiredReviewSessionId();
    state = AsyncData(current.copyWith(isFinalizing: true));
    try {
      final result = await _repository.finalizeReview(
        reviewSessionId,
        language: language,
      );
      state = AsyncData(
        (state.valueOrNull ?? current).copyWith(
          finalizeResult: result,
          isFinalizing: false,
        ),
      );
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  String _requiredReviewSessionId() {
    final reviewSessionId = state.valueOrNull?.reviewSessionId;
    if (reviewSessionId == null || reviewSessionId.isEmpty) {
      throw StateError('No review session is loaded.');
    }
    return reviewSessionId;
  }

  Future<List<IssueGroupSummary>?> _safeLoadGroups(
    String? reviewSessionId,
  ) async {
    if (reviewSessionId == null || reviewSessionId.isEmpty) return null;
    try {
      return await _repository.getIssueGroups(reviewSessionId);
    } catch (_) {
      return null;
    }
  }

  Map<String, List<IssueItem>> _markIssues(
    Map<String, List<IssueItem>> source, {
    String? issueId,
    String? groupId,
    required bool allPending,
    required String status,
  }) {
    return source.map((key, issues) {
      final shouldUpdateGroup = allPending || groupId == key;
      return MapEntry(
        key,
        issues
            .map((issue) {
              final shouldUpdateIssue = issueId == issue.issueId;
              if ((shouldUpdateGroup || shouldUpdateIssue) &&
                  issue.status == 'pending') {
                return issue.copyWith(status: status);
              }
              return issue;
            })
            .toList(growable: false),
      );
    });
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/analysis_models.dart';
import '../../data/models/dataset_models.dart';
import '../../domain/repositories/data_review_repository.dart';
import 'data_review_providers.dart';

final analysisControllerProvider =
    StateNotifierProvider<AnalysisController, AsyncValue<AnalysisState>>((ref) {
      return AnalysisController(ref.watch(dataReviewRepositoryProvider));
    });

class AnalysisState {
  const AnalysisState({
    this.eligibleDatasets = const [],
    this.selectedDatasetIds = const {},
    this.isBusy = false,
    this.jobStatus,
    this.report,
  });

  final List<EligibleDatasetItem> eligibleDatasets;
  final Set<String> selectedDatasetIds;
  final bool isBusy;
  final AnalysisJobStatus? jobStatus;
  final AnalysisReport? report;

  AnalysisState copyWith({
    List<EligibleDatasetItem>? eligibleDatasets,
    Set<String>? selectedDatasetIds,
    bool? isBusy,
    AnalysisJobStatus? jobStatus,
    AnalysisReport? report,
  }) {
    return AnalysisState(
      eligibleDatasets: eligibleDatasets ?? this.eligibleDatasets,
      selectedDatasetIds: selectedDatasetIds ?? this.selectedDatasetIds,
      isBusy: isBusy ?? this.isBusy,
      jobStatus: jobStatus ?? this.jobStatus,
      report: report ?? this.report,
    );
  }
}

class AnalysisController extends StateNotifier<AsyncValue<AnalysisState>> {
  AnalysisController(this._repository) : super(const AsyncLoading()) {
    loadEligibleDatasets();
  }

  final DataReviewRepository _repository;

  Future<void> loadEligibleDatasets() async {
    try {
      final items = await _repository.getEligibleDatasets();
      state = AsyncData(AnalysisState(eligibleDatasets: items));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void toggleDataset(String datasetId, bool selected) {
    final current = state.valueOrNull ?? const AnalysisState();
    final ids = {...current.selectedDatasetIds};
    selected ? ids.add(datasetId) : ids.remove(datasetId);
    state = AsyncData(current.copyWith(selectedDatasetIds: ids));
  }

  Future<DatasetPreviewBundle> previewDataset(EligibleDatasetItem item) async {
    final detail = await _repository.getDatasetDetail(item.datasetId);
    final preview = await _repository.getDatasetPreview(item.datasetId);
    return DatasetPreviewBundle(
      datasetId: item.datasetId,
      sheets: detail.sheets,
      preview: preview,
    );
  }

  Future<AnalysisReport> startAnalysis({
    required List<String> datasetIds,
    required String prompt,
    required String language,
  }) async {
    final current = state.valueOrNull ?? const AnalysisState();
    state = AsyncData(current.copyWith(isBusy: true));

    try {
      final job = await _repository.createAnalysisJob(
        datasetIds: datasetIds,
        prompt: prompt,
        language: language,
      );
      AnalysisJobStatus status;
      for (var i = 0; i < 120; i++) {
        status = await _repository.getAnalysisJobStatus(job.analysisJobId);
        final latest = state.valueOrNull ?? current;
        state = AsyncData(latest.copyWith(jobStatus: status, isBusy: true));
        if (status.status == 'completed') {
          final report = await _repository.getAnalysisReport(job.analysisJobId);
          state = AsyncData(
            (state.valueOrNull ?? latest).copyWith(
              isBusy: false,
              report: report,
            ),
          );
          return report;
        }
        if (status.status == 'failed') {
          throw AnalysisFailedException(
            status.errorMessage ?? 'Analysis failed.',
          );
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      throw TimeoutException('Analysis did not finish in time.');
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<List<int>> downloadReportPdf(String jobId) {
    return _repository.downloadReportPdf(jobId);
  }
}

class AnalysisFailedException implements Exception {
  const AnalysisFailedException(this.message);

  final String message;

  @override
  String toString() => message;
}

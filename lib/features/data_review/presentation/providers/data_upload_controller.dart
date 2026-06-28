import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dataset_models.dart';
import '../../domain/repositories/data_review_repository.dart';
import 'data_review_providers.dart';

final dataUploadControllerProvider =
    StateNotifierProvider.autoDispose<
      DataUploadController,
      AsyncValue<DataUploadState>
    >((ref) {
      return DataUploadController(ref.watch(dataReviewRepositoryProvider));
    });

class DataUploadState {
  const DataUploadState({this.filename, this.result, this.isUploading = false});

  final String? filename;
  final UploadDatasetResult? result;
  final bool isUploading;

  DataUploadState copyWith({
    String? filename,
    UploadDatasetResult? result,
    bool? isUploading,
  }) {
    return DataUploadState(
      filename: filename ?? this.filename,
      result: result ?? this.result,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class DataUploadController extends StateNotifier<AsyncValue<DataUploadState>> {
  DataUploadController(this._repository)
    : super(const AsyncData(DataUploadState()));

  final DataReviewRepository _repository;

  Future<UploadDatasetResult?> pickAndUpload({
    required String language,
    String projectId = 'COMMUNITY_AGENT',
  }) async {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls', 'xlsm', 'csv'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;

    final file = picked.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Selected file bytes were not available.');
    }

    final current = state.valueOrNull ?? const DataUploadState();
    state = AsyncData(current.copyWith(filename: file.name, isUploading: true));

    try {
      final result = await _repository.uploadDataset(
        bytes: bytes,
        filename: file.name,
        projectId: projectId,
        language: language,
      );
      state = AsyncData(
        DataUploadState(
          filename: file.name,
          result: result,
          isUploading: false,
        ),
      );
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

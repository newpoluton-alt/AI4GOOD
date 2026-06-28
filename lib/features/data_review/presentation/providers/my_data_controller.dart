import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/dataset_models.dart';
import '../../domain/repositories/data_review_repository.dart';
import 'data_review_providers.dart';

final myDataControllerProvider =
    StateNotifierProvider.autoDispose<
      MyDataController,
      AsyncValue<MyDataState>
    >((ref) {
      return MyDataController(ref.watch(dataReviewRepositoryProvider));
    });

class MyDataState {
  const MyDataState({this.items = const [], this.isBusy = false});

  final List<MyDataItem> items;
  final bool isBusy;

  MyDataState copyWith({List<MyDataItem>? items, bool? isBusy}) {
    return MyDataState(
      items: items ?? this.items,
      isBusy: isBusy ?? this.isBusy,
    );
  }
}

class MyDataController extends StateNotifier<AsyncValue<MyDataState>> {
  MyDataController(this._repository) : super(const AsyncLoading()) {
    load();
  }

  final DataReviewRepository _repository;

  Future<void> load() async {
    try {
      final items = await _repository.getMyData();
      state = AsyncData(MyDataState(items: items));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteDataset(String datasetId) async {
    final current = state.valueOrNull ?? const MyDataState();
    state = AsyncData(current.copyWith(isBusy: true));
    try {
      await _repository.deleteDataset(datasetId);
      final items = current.items
          .where((item) => item.datasetId != datasetId)
          .toList(growable: false);
      state = AsyncData(MyDataState(items: items));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAll() async {
    final current = state.valueOrNull ?? const MyDataState();
    state = AsyncData(current.copyWith(isBusy: true));
    try {
      await _repository.deleteAllMyData();
      state = const AsyncData(MyDataState());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<DatasetPreviewBundle> previewDataset(MyDataItem item) async {
    final detail = await _repository.getDatasetDetail(item.datasetId);
    final preview = await _repository.getDatasetPreview(item.datasetId);
    return DatasetPreviewBundle(
      datasetId: item.datasetId,
      sheets: detail.sheets,
      preview: preview,
    );
  }

  Future<DownloadLink> processedDownload(String datasetId) {
    return _repository.getProcessedDownload(datasetId);
  }
}

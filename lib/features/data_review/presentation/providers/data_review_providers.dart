import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/localization/language_controller.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/data_review_remote_data_source.dart';
import '../../data/repositories/data_review_repository_impl.dart';
import '../../domain/repositories/data_review_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final language =
      ref.watch(languageControllerProvider).valueOrNull?.languageCode ?? 'en';
  final client = http.Client();
  ref.onDispose(client.close);

  return ApiClient(
    baseUrl: ApiConfig.baseUrl,
    firebaseAuth: FirebaseAuth.instance,
    client: client,
    languageCode: language,
  );
});

final dataReviewRemoteDataSourceProvider = Provider<DataReviewRemoteDataSource>(
  (ref) {
    return DataReviewRemoteDataSourceImpl(ref.watch(apiClientProvider));
  },
);

final dataReviewRepositoryProvider = Provider<DataReviewRepository>((ref) {
  return DataReviewRepositoryImpl(
    ref.watch(dataReviewRemoteDataSourceProvider),
  );
});

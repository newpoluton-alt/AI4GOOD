import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ChangeEmail implements UseCase<void, String> {
  const ChangeEmail(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.changeEmail(params);
  }
}

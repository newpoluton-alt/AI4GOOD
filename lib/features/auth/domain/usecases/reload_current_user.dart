import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class ReloadCurrentUser implements UseCase<AppUser?, NoParams> {
  const ReloadCurrentUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) {
    return repository.reloadCurrentUser();
  }
}

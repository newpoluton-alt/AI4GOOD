import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerification implements UseCase<void, NoParams> {
  const SendEmailVerification(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.sendEmailVerification();
  }
}

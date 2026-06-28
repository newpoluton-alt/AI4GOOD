import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignIn implements UseCase<AppUser, SignInParams> {
  const SignIn(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, AppUser>> call(SignInParams params) {
    return repository.signIn(email: params.email, password: params.password);
  }
}

class SignInParams extends Equatable {
  const SignInParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

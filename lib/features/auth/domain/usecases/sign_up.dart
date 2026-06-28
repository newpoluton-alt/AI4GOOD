import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignUp implements UseCase<AppUser, SignUpParams> {
  const SignUp(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, AppUser>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpParams extends Equatable {
  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, AppUser?>> reloadCurrentUser();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> changeEmail(String newEmail);
}

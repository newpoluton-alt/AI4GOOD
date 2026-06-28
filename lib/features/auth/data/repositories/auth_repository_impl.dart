import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remoteDataSource);

  final AuthRemoteDataSource remoteDataSource;

  @override
  Stream<AppUser?> authStateChanges() {
    return remoteDataSource.authStateChanges();
  }

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() {
      return remoteDataSource.signIn(email: email, password: password);
    });
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _guard(() {
      return remoteDataSource.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return _guard(() => remoteDataSource.sendPasswordResetEmail(email));
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() {
    return _guard(remoteDataSource.sendEmailVerification);
  }

  @override
  Future<Either<Failure, AppUser?>> reloadCurrentUser() {
    return _guard(remoteDataSource.reloadCurrentUser);
  }

  @override
  Future<Either<Failure, void>> signOut() {
    return _guard(remoteDataSource.signOut);
  }

  @override
  Future<Either<Failure, void>> changeEmail(String newEmail) {
    return _guard(() => remoteDataSource.changeEmail(newEmail));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on FirebaseAuthException catch (error) {
      return Left(Failure(_friendlyAuthMessage(error)));
    } on FirebaseException catch (error) {
      return Left(Failure(error.message ?? 'Firebase request failed.'));
    } catch (_) {
      return const Left(Failure('Something went wrong. Please try again.'));
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again before changing your email.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

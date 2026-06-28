import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_email.dart';
import '../../domain/usecases/reload_current_user.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return FirebaseAuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final signInProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(authRepositoryProvider));
});

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(ref.watch(authRepositoryProvider));
});

final sendPasswordResetEmailProvider = Provider<SendPasswordResetEmail>((ref) {
  return SendPasswordResetEmail(ref.watch(authRepositoryProvider));
});

final sendEmailVerificationProvider = Provider<SendEmailVerification>((ref) {
  return SendEmailVerification(ref.watch(authRepositoryProvider));
});

final reloadCurrentUserProvider = Provider<ReloadCurrentUser>((ref) {
  return ReloadCurrentUser(ref.watch(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(authRepositoryProvider));
});

final changeEmailProvider = Provider<ChangeEmail>((ref) {
  return ChangeEmail(ref.watch(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<String?> signIn({required String email, required String password}) {
    return _run(
      () => _ref.read(signInProvider)(
        SignInParams(email: email, password: password),
      ),
    );
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _run(
      () => _ref.read(signUpProvider)(
        SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      ),
    );
  }

  Future<String?> sendPasswordResetEmail(String email) {
    return _run(() => _ref.read(sendPasswordResetEmailProvider)(email));
  }

  Future<String?> sendEmailVerification() {
    return _run(() {
      return _ref.read(sendEmailVerificationProvider)(const NoParams());
    });
  }

  Future<String?> reloadCurrentUser() {
    return _run(() {
      return _ref.read(reloadCurrentUserProvider)(const NoParams());
    });
  }

  Future<String?> signOut() {
    return _run(() => _ref.read(signOutProvider)(const NoParams()));
  }

  Future<String?> changeEmail(String newEmail) {
    return _run(() => _ref.read(changeEmailProvider)(newEmail));
  }

  Future<String?> _run<T>(Future<dynamic> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncData(null);
        return null;
      },
    );
  }
}

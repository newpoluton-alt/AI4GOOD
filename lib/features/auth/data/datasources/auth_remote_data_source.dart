import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUserModel?> authStateChanges();

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });

  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<AppUserModel?> reloadCurrentUser();

  Future<void> signOut();

  Future<void> changeEmail(String newEmail);
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const FirebaseAuthRemoteDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUserModel?> authStateChanges() {
    return _firebaseAuth.userChanges().map((user) {
      if (user == null) return null;
      return AppUserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to sign in with these credentials.',
      );
    }
    return AppUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'account-not-created',
        message: 'Unable to create your account.',
      );
    }

    final cleanDisplayName = displayName.trim();
    await user.updateDisplayName(cleanDisplayName);
    await user.sendEmailVerification();
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'emailVerified': user.emailVerified,
      'displayName': cleanDisplayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await user.reload();
    return AppUserModel.fromFirebaseUser(_firebaseAuth.currentUser ?? user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Please sign in again to verify your email.',
      );
    }
    if (user.emailVerified) return;
    await user.sendEmailVerification();
  }

  @override
  Future<AppUserModel?> reloadCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    await user.reload();
    final reloadedUser = _firebaseAuth.currentUser;
    if (reloadedUser == null) return null;

    await _firestore.collection('users').doc(reloadedUser.uid).set({
      'email': reloadedUser.email,
      'emailVerified': reloadedUser.emailVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return AppUserModel.fromFirebaseUser(reloadedUser);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> changeEmail(String newEmail) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Please sign in again to change your email.',
      );
    }
    await user.verifyBeforeUpdateEmail(newEmail.trim());
    await _firestore.collection('users').doc(user.uid).set({
      'pendingEmail': newEmail.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

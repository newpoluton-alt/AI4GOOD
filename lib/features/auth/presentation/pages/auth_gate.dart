import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/app_ui.dart';
import '../../../landing/presentation/pages/landing_page.dart';
import '../providers/auth_providers.dart';
import 'auth_page.dart';
import 'email_verification_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const AuthPage();
        if (!user.isEmailVerified) return EmailVerificationPage(user: user);
        return const LandingPage();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: SafeArea(child: AppErrorView(message: error.toString())),
      ),
    );
  }
}

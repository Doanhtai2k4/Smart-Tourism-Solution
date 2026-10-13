import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'brand_icon.dart';

import '../../features/auth/provider/auth_providers.dart';

class SignInButton extends ConsumerWidget {
  const SignInButton({super.key});

  void googleSignIn(BuildContext context, WidgetRef ref){
    ref.read(authStateProvider.notifier).signInWithGoogle();
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => googleSignIn(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Brand(Brands.google, size: 28),
              SizedBox(width: 8),
              Text(
                'Tiếp tục với Google',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/core/widgets/custom_auth_widgets.dart';

import '../../../core/extensions/context_l10n.dart';
import '../models/user_model.dart';
import '../provider/auth_providers.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void signUpClicked() {
    if (_formKey.currentState!.validate()) {
      ref.read(authStateProvider.notifier).signUp(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Listen for errors and show SnackBar
    ref.listen<AsyncValue<UserModel?>>(authStateProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sign_up_title,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.sign_up_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 32),

                  CustomTextField(
                    controller: emailController,
                    hintText: l10n.email_hint,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.email_required;
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return l10n.email_invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: passwordController,
                    hintText: l10n.password_hint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return l10n.password_invalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: confirmPasswordController,
                    hintText: l10n.confirmPassword,
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.confirmPassword; // Should be confirm_password_required if we had it
                      }
                      if (value != passwordController.text) {
                        return l10n.passwordsDontMatch;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  CustomPrimaryButton(
                    onPressed: signUpClicked,
                    text: l10n.sign_up_button,
                    isLoading: authState.isLoading,
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.goNamed('signIn'),
                          child: Text(
                            l10n.sign_in_button,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

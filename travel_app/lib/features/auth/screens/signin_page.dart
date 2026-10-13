import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app/shared/widgets/brand_icon.dart';
import 'package:travel_app/core/extensions/context_l10n.dart';
import 'package:travel_app/core/widgets/custom_auth_widgets.dart';
import '../../../core/theme/app_colors.dart';
import '../provider/auth_providers.dart';
import '../../../core/routing/app_routes.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Lắng nghe lỗi để hiển thị SnackBar
    ref.listen<AsyncValue>(authStateProvider, (previous, next) {
      debugPrint('SigninPage: authState update: $next');
      next.whenOrNull(
        error: (error, stack) {
          debugPrint('SigninPage: Auth ERROR: $error\n$stack');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    l10n.auth_welcome_back_title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.auth_welcome_back_subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 48),

                  // Email
                  CustomTextField(
                    controller: emailController,
                    hintText: l10n.email,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.email_required;
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return l10n.email_invalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    controller: passwordController,
                    hintText: l10n.password,
                    prefixIcon: Icons.lock_outline,
                    obscureText: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.password_invalid; // Should really be password_required if we had it, but l10n file used password_invalid for hint/error
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // Quên mật khẩu logic có thể thêm sau
                      child: Text(l10n.auth_forgot_password_question),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  CustomPrimaryButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authStateProvider.notifier).signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      }
                    },
                    text: l10n.signIn,
                    isLoading: authState.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.auth_or_divider,
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(authStateProvider.notifier).signInWithGoogle(),
                      icon: Brand(Brands.google, size: 24),
                      label: Text(
                        l10n.auth_continue_with_google,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: AppColors.border),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.auth_no_account_yet),
                      TextButton(
                        onPressed: () => context.goNamed(RouteNames.signUp),
                        child: Text(
                          l10n.auth_sign_up_now,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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

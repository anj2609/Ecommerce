import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_app/core/theme/app_theme.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C5CE7),
              Color(0xFFA29BFE),
              Color(0xFF74B9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                    const Spacer(flex: 2),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'ShopVibe',
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover amazing products\nat unbeatable prices',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(flex: 2),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: authState.status == AuthStatus.loading
                              ? null
                              : () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (authState.status == AuthStatus.loading)
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                else
                                  Image.network(
                                    'https://www.google.com/favicon.ico',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.g_mobiledata_rounded,
                                      size: 28,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  authState.status == AuthStatus.loading
                                      ? 'Signing in...'
                                      : 'Continue with Google',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'By continuing, you agree to our\nTerms of Service & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  ),
),
);
  }
}

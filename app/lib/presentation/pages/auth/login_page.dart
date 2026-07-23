import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/brand_logo.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppAnimation.slow,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).login(username, password);

      if (!mounted) return;

      final authState = ref.read(authStateProvider);
      if (authState is AuthAuthenticated) {
        context.go('/report');
      } else if (authState is AuthError) {
        setState(() {
          _isLoading = false;
          _errorMessage = authState.message;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Login failed. Please check your credentials.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.sidebar,
      body: Container(
        color: colors.sidebar,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: 400,
              child: GlassPanel(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandLogo(size: 56),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Newsletter',
                        style: AppTypography.headlineLarge.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Media Monitoring Portal',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      if (_isLoading)
                        _buildLoadingState(colors)
                      else
                        _buildForm(colors),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: colors.textPrimary,
              backgroundColor: colors.border,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Signing in…',
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppColors colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTextField(
          controller: _usernameController,
          hint: 'Username',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _passwordController,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _handleLogin,
            child: Text(
              'Sign in',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onAccent,
              ),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/register'),
          child: Text(
            "Don't have an account? Register",
            style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: !_isLoading,
      onSubmitted: (_) {
        if (!_isLoading) _handleLogin();
      },
      style: AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textSecondary),
        prefixIcon: Icon(icon, color: AppColors.of(context).textTertiary, size: 20),
        filled: true,
        fillColor: AppColors.of(context).surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.of(context).border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.of(context).border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.of(context).textPrimary, width: 1.5),
        ),
      ),
    );
  }
}

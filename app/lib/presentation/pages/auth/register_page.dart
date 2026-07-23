import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/brand_logo.dart';
import 'package:newsletter_portal/presentation/widgets/glass_panel.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
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
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_passwordController.text != _confirmController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
        _isLoading = false;
      });
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).register(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      
      if (mounted && ref.read(authStateProvider) is AuthAuthenticated) {
        context.go('/report');
      } else {
        setState(() => _errorMessage = 'Registration failed.');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).sidebar,
      body: Container(
        color: AppColors.of(context).sidebar,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: 400,
              child: GlassPanel(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BrandLogo(size: 56),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Newsletter',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.of(context).textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an Account',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 12),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        'Password must be at least 8 characters long.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                    _buildTextField(
                      controller: _confirmController,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text('Create account', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.onAccent)),
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
                      onPressed: () => context.go('/login'),
                      child: Text(
                        "Already have an account? Login",
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePass = true;

  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();
    final ok =
        await provider.signIn(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Login failed'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      provider.clearError();
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Enter your email first')));
      return;
    }
    final provider = context.read<AppProvider>();
    await provider.sendPasswordReset(_emailCtrl.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset email sent!'),
          backgroundColor: AppTheme.safeGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.watch<AppProvider>().state == AppState.loading;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.shield_rounded,
                              color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text('Welcome Back',
                          style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('Sign in to continue',
                          style: GoogleFonts.outfit(
                              fontSize: 15, color: Colors.white54)),
                      const SizedBox(height: 40),

                      CustomTextField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            !v!.contains('@') ? 'Enter valid email' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        icon: Icons.lock_rounded,
                        obscureText: _obscurePass,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: Colors.white54,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                        validator: (v) =>
                            v!.isEmpty ? 'Enter password' : null,
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: Text('Forgot Password?',
                              style: GoogleFonts.outfit(
                                  color: AppTheme.accentBlue)),
                        ),
                      ),

                      const SizedBox(height: 12),
                      GradientButton(text: 'Sign In', onTap: _login),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: GoogleFonts.outfit(
                                  color: Colors.white54)),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/user-type'),
                            child: Text('Sign Up',
                                style: GoogleFonts.outfit(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
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
}

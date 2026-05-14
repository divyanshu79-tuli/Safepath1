import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _guardianEmailCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();

  bool _obscurePass = true;
  String _userType = 'user';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) _userType = args;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _guardianEmailCtrl.dispose();
    _guardianNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AppProvider>();

    final ok = await provider.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passwordCtrl.text,
      userType: _userType,
      guardianEmail: _guardianEmailCtrl.text.trim().isEmpty
          ? null
          : _guardianEmailCtrl.text.trim(),
      guardianName: _guardianNameCtrl.text.trim().isEmpty
          ? null
          : _guardianNameCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Signup failed'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      provider.clearError();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text('Create Account',
                        style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Join Safepath today',
                        style: GoogleFonts.outfit(
                            fontSize: 15, color: Colors.white54)),
                    const SizedBox(height: 32),

                    // Fields
                    CustomTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      icon: Icons.person_rounded,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
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
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter phone number' : null,
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
                      validator: (v) => v!.length < 6
                          ? 'Password must be 6+ characters'
                          : null,
                    ),

                    const SizedBox(height: 24),
                    // Guardian section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.shield_outlined,
                                color: AppTheme.primaryBlue, size: 18),
                            const SizedBox(width: 8),
                            Text('Guardian Info (Optional)',
                                style: GoogleFonts.outfit(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _guardianNameCtrl,
                            label: "Guardian's Name",
                            icon: Icons.person_outline_rounded,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _guardianEmailCtrl,
                            label: "Guardian's Email",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    GradientButton(
                      text: 'Create Account',
                      onTap: _submit,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: GoogleFonts.outfit(
                                color: Colors.white54)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: Text('Sign In',
                              style: GoogleFonts.outfit(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

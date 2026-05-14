import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class GuardianSetupScreen extends StatefulWidget {
  const GuardianSetupScreen({super.key});

  @override
  State<GuardianSetupScreen> createState() => _GuardianSetupScreenState();
}

class _GuardianSetupScreenState extends State<GuardianSetupScreen> {
  final _guardianNameCtrl = TextEditingController();
  final _guardianEmailCtrl = TextEditingController();
  double _selectedRadius = 500;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    if (user != null) {
      _guardianNameCtrl.text = user.guardianName ?? '';
      _guardianEmailCtrl.text = user.guardianEmail ?? '';
      _selectedRadius = user.safeRadiusMeters ?? 500;
    }
  }

  @override
  void dispose() {
    _guardianNameCtrl.dispose();
    _guardianEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await context.read<AppProvider>().updateUserField({
      'guardianName': _guardianNameCtrl.text.trim(),
      'guardianEmail': _guardianEmailCtrl.text.trim(),
      'safeRadiusMeters': _selectedRadius,
    });
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Guardian settings saved!'),
          backgroundColor: AppTheme.safeGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0E1A), const Color(0xFF111827)]
                : [const Color(0xFFEFF6FF), const Color(0xFFDDE9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Guardian Setup',
                      style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Guardian info card
                _SectionCard(
                  isDark: isDark,
                  title: '👤 Guardian Information',
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _guardianNameCtrl,
                        label: "Guardian's Full Name",
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _guardianEmailCtrl,
                        label: "Guardian's Email",
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Safe radius selector
                _SectionCard(
                  isDark: isDark,
                  title: '🎯 Safe Zone Radius',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select the radius of the safe zone',
                        style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          AppConstants.safeRadiusOptions.length,
                          (i) => _RadiusChip(
                            label: AppConstants.safeRadiusLabels[i],
                            value: AppConstants.safeRadiusOptions[i],
                            isSelected:
                                _selectedRadius == AppConstants.safeRadiusOptions[i],
                            onTap: () => setState(
                                () => _selectedRadius =
                                    AppConstants.safeRadiusOptions[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Slider
                      Text(
                        'Custom: ${_selectedRadius.toStringAsFixed(0)}m',
                        style: GoogleFonts.outfit(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: _selectedRadius,
                        min: 50,
                        max: 2000,
                        divisions: 39,
                        activeColor: AppTheme.primaryBlue,
                        inactiveColor: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFBFDBFE),
                        onChanged: (v) =>
                            setState(() => _selectedRadius = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your guardian will receive email & push alerts when you leave this zone.',
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                _isSaving
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryBlue))
                    : GradientButton(text: 'Save Settings', onTap: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _SectionCard(
      {required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? const Color(0xFF374151)
                : const Color(0xFFBFDBFE),
            width: 0.8),
        boxShadow: [
          BoxShadow(
              color: isDark
                  ? Colors.black26
                  : const Color(0xFF4F8EF7).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  final String label;
  final double value;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadiusChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : const Color(0xFF374151),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
      ),
    );
  }
}

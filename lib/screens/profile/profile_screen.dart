import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/gradient_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().currentUser;
    _nameCtrl.text = user?.name ?? '';
    _phoneCtrl.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    await context.read<AppProvider>().updateUserField({
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    });
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated!'),
        backgroundColor: AppTheme.safeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
            'You will be signed out of Safepath.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm == true) {
      await context.read<AppProvider>().signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final isDark = provider.isDarkMode;

    return Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (user?.name.isNotEmpty == true)
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.outfit(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isEditing = !_isEditing),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: AppTheme.primaryBlue, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user?.name ?? 'User',
                        style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(user?.email ?? '',
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        (user?.userType ?? 'user')
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Edit form (conditionally shown)
              if (_isEditing) ...[
                _SectionCard(
                  isDark: isDark,
                  title: '✏️ Edit Profile',
                  child: Column(
                    children: [
                      CustomTextField(
                          controller: _nameCtrl,
                          label: 'Full Name',
                          icon: Icons.person_rounded),
                      const SizedBox(height: 14),
                      CustomTextField(
                          controller: _phoneCtrl,
                          label: 'Phone',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _isSaving
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue))
                          : GradientButton(
                              text: 'Save Changes', onTap: _saveProfile),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Settings section
              _SectionCard(
                isDark: isDark,
                title: '⚙️ Settings',
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark Mode',
                      trailing: Switch(
                        value: provider.isDarkMode,
                        onChanged: (_) => provider.toggleDarkMode(),
                       activeThumbColor: AppTheme.primaryBlue,
                      ),
                      isDark: isDark,
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.record_voice_over_rounded,
                      label: 'Voice Assistant',
                      trailing: Switch(
                        value: provider.isVoiceEnabled,
                        onChanged: (_) => provider.toggleVoice(),
                       activeThumbColor: AppTheme.primaryBlue,
                      ),
                      isDark: isDark,
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.text_fields_rounded,
                      label: 'Large Text',
                      trailing: Switch(
                        value: provider.isLargeText,
                        onChanged: (_) => provider.toggleLargeText(),
                       activeThumbColor: AppTheme.primaryBlue,
                      ),
                      isDark: isDark,
                    ),
                    _Divider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.contrast_rounded,
                      label: 'High Contrast',
                      trailing: Switch(
                        value: provider.isHighContrast,
                        onChanged: (_) => provider.toggleHighContrast(),
                       activeThumbColor: AppTheme.primaryBlue,
                      ),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Guardian settings shortcut
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/guardian-setup'),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Guardian Settings',
                                style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B))),
                            Text('Update safe zone & guardian info',
                                style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign out
              GestureDetector(
                onTap: _signOut,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.dangerRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppTheme.dangerRed.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: AppTheme.dangerRed),
                      const SizedBox(width: 10),
                      Text('Sign Out',
                          style: GoogleFonts.outfit(
                              color: AppTheme.dangerRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? const Color(0xFF374151)
                : const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1E293B))),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool isDark;

  const _SettingsTile(
      {required this.icon,
      required this.label,
      required this.trailing,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              color: AppTheme.primaryBlue, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF1E293B))),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
        color: isDark
            ? const Color(0xFF374151)
            : const Color(0xFFE2E8F0),
        height: 1);
  }
}

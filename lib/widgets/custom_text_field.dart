import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Styled text field for dark/light mode
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.outfit(
        color: isDark ? Colors.white : const Color(0xFF1E293B),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,
            color: isDark ? Colors.white38 : Colors.blueGrey, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

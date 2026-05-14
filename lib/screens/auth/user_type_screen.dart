import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  String? _selected;

  final List<Map<String, dynamic>> _types = AppConstants.userTypes;

  final List<List<Color>> _gradients = [
    [Color(0xFF4F8EF7), Color(0xFF7C3AED)],
    [Color(0xFFEC4899), Color(0xFF7C3AED)],
    [Color(0xFF10B981), Color(0xFF4F8EF7)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF06B6D4), Color(0xFF3B82F6)],
  ];

  void _proceed() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your user type')),
      );
      return;
    }
    Navigator.pushNamed(context, '/signup', arguments: _selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Who are you?',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your profile to personalise your experience',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: ListView.separated(
                    itemCount: _types.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _UserTypeCard(
                      data: _types[i],
                      gradient: _gradients[i],
                      isSelected: _selected == _types[i]['id'],
                      onTap: () =>
                          setState(() => _selected = _types[i]['id']),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _proceed,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: _selected != null
                          ? AppTheme.primaryGradient
                          : const LinearGradient(
                              colors: [Color(0xFF374151), Color(0xFF374151)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _selected != null
                          ? [
                              BoxShadow(
                                color:
                                    AppTheme.primaryBlue.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        'Continue',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final List<Color> gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.data,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_UserTypeCard> createState() => _UserTypeCardState();
}

class _UserTypeCardState extends State<_UserTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(colors: widget.gradient)
                : null,
            color: widget.isSelected ? null : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : const Color(0xFF374151),
              width: 1.5,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.gradient.first.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Text(widget.data['icon'],
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data['label'],
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.data['description'],
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

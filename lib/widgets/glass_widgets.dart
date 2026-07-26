import 'package:flutter/material.dart';

/// ============================================================
/// FINAL THEME — flat, bordered "outline glass" in a single blue
/// accent. No green, no blur, no shadows. Light/dark are mirror
/// images of each other (black<->white swap) with blue held constant.
///
/// Reads Theme.of(context).brightness, so wire light/dark by
/// setting MaterialApp's theme/darkTheme/themeMode as usual —
/// these widgets follow automatically, no extra plumbing needed.
/// ============================================================

class AppColors {
  final Color background;
  final Color surface;
  final Color border;
  final Color neutralBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color avatarFill;
  final Color avatarText;
  final Color buttonText;
  final Color danger;

  const AppColors({
    required this.background,
    required this.surface,
    required this.border,
    required this.neutralBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.avatarFill,
    required this.avatarText,
    required this.buttonText,
    required this.danger,
  });

  static AppColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? dark : light;
  }

  static const light = AppColors(
    background: Color(0xFFF2F2F3),
    surface: Colors.white,
    border: Color(0x552563EB),
    neutralBorder: Color(0x1F0A0A0A),
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xA60A0A0A),
    accent: Color(0xFF2563EB),
    avatarFill: Color(0xFF0A0A0A),
    avatarText: Colors.white,
    buttonText: Colors.white,
    danger: Color(0xFFDC2626),
  );

  static const dark = AppColors(
    background: Color(0xFF000814),
    surface: Color(0xFF000814),
    border: Color(0x663B82F6),
    neutralBorder: Color(0x1FFFFFFF),
    textPrimary: Colors.white,
    textSecondary: Color(0xA6FFFFFF),
    accent: Color(0xFF3B82F6),
    avatarFill: Colors.white,
    avatarText: Color(0xFF0A0A0A),
    buttonText: Colors.white,
    danger: Color(0xFFEF4444),
  );
}

@Deprecated('Use AppColors.of(context).accent')
const kAuthAccentMint = Color(0xFF3B82F6);
@Deprecated('Use AppColors.of(context).accent')
const kAuthAccentGreen = Color(0xFF3B82F6);
@Deprecated('Use AppColors.of(context).accent')
const kAuthAccentBlue = Color(0xFF3B82F6);
@Deprecated('Use AppColors.of(context).accent')
const kAuthAccentSkyBlue = Color(0xFF2563EB);

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      color: colors.background,
      child: SafeArea(child: child),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      width: 340,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: colors.accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border, width: 1.3),
      ),
      child: child,
    );
  }
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: child,
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Text(
      text,
      style: TextStyle(
        color: colors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
  }
}

class GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool suffixDot;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffixDot = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.surface.withOpacity(0.04) : colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.neutralBorder),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        autofillHints: null,
        enableSuggestions: false,
        autocorrect: false,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          hintText: hint,
          hintStyle: TextStyle(color: colors.textSecondary.withOpacity(0.6)),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(color: colors.danger, fontSize: 11),
          suffixIcon: suffixIcon ??
              (suffixDot
                  ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(Icons.circle, color: colors.accent, size: 8),
              )
                  : null),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}

class GlassGradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const GlassGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colors.accent,
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        )
            : Text(
          label,
          style: TextStyle(
            color: colors.buttonText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AuthErrorText extends StatelessWidget {
  final String message;
  const AuthErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.danger.withOpacity(0.35)),
        ),
        child: Text(
          message,
          style: TextStyle(color: colors.danger, fontSize: 12.5),
        ),
      ),
    );
  }
}

class RoleToggle extends StatelessWidget {
  final List<String> roles;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const RoleToggle({
    super.key,
    required this.roles,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(roles.length, (i) {
          final isSelected = roles[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(roles[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isSelected ? colors.accent : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? colors.buttonText : colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class GlassListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const GlassListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(color: colors.textSecondary, fontSize: 11.5),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class GlassIconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const GlassIconAction({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class GlassSelectorChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const GlassSelectorChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Icon(Icons.unfold_more, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
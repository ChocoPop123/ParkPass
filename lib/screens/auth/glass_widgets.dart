import 'dart:ui';
import 'package:flutter/material.dart';

/// Shared glassmorphic building blocks for the auth flow (login/signup).
/// Keeping these in one file means both screens stay visually in sync —
/// change a color or radius here and it updates everywhere.

const kAuthAccentBlue = Color(0xFF3B82F6);
const kAuthAccentSkyBlue = Color(0xFF2563EB);
const kAuthAccentGreen = Color(0xFF34D399);
const kAuthAccentMint = Color(0xFF6EE7B7);

/// Full-bleed background with blurred blue/green orbs and a faint bus mark.
/// Wrap your Scaffold body's Stack with this at the bottom layer.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Lighter, cooler base than pure black — dark teal-navy instead of dark purple.
        Container(color: const Color(0xFF0E1A1B)),
        const _BackgroundBus(),
        SafeArea(child: child),
      ],
    );
  }
}

/// A soft, blurred bus silhouette sitting behind the card — a subtle
/// nod to the app's domain without competing with the form.
class _BackgroundBus extends StatelessWidget {
  const _BackgroundBus();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 90,
      right: -40,
      child: Transform.rotate(
        angle: -0.12,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Opacity(
            opacity: 0.22,
            child: Icon(
              Icons.directions_bus_filled_rounded,
              size: 260,
              color: kAuthAccentMint,
            ),
          ),
        ),
      ),
    );
  }
}

/// The frosted glass card that holds the form — lighter and greener
/// than a standard dark glass panel.
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 340,
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kAuthAccentBlue.withOpacity(0.14),
                kAuthAccentGreen.withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.65),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// Glass-styled text field. Pass a [validator] to plug into a Form if desired.
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        autofillHints: null,
        enableSuggestions: false,
        autocorrect: false,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        cursorColor: kAuthAccentMint,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: const TextStyle(
            color: Color(0xFFFF6B81),
            fontSize: 11,
          ),
          suffixIcon: suffixIcon ??
              (suffixDot
                  ? const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.circle, color: kAuthAccentMint, size: 8),
              )
                  : null),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}

/// Light glass-blue pill button with a built-in loading spinner state.
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
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [kAuthAccentBlue, kAuthAccentSkyBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: kAuthAccentSkyBlue.withOpacity(0.45),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Inline error banner, styled to fit the glass theme.
class AuthErrorText extends StatelessWidget {
  final String message;
  const AuthErrorText(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B81).withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFF6B81).withOpacity(0.3)),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFFFF6B81), fontSize: 12.5),
        ),
      ),
    );
  }
}

/// "Passenger / Conductor" style segmented role selector for signup.
class RoleToggle extends StatelessWidget {
  final List<String> roles; // e.g. ['passenger', 'conductor']
  final List<String> labels; // e.g. ['Passenger', 'Conductor']
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                  gradient: isSelected
                      ? const LinearGradient(
                    colors: [kAuthAccentBlue, kAuthAccentSkyBlue],
                  )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.55),
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
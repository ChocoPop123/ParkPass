import 'package:flutter/material.dart';
import 'glass_widgets.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  
  const AppLogo({
    super.key, 
    this.size = 100,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Container(
      decoration : BoxDecoration(
        borderRadius : BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

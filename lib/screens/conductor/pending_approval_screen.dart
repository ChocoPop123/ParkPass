import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/glass_widgets.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_top_rounded, color: colors.accent, size: 40),
                  const SizedBox(height: 16),
                  Text('Pending Approval',
                      style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(
                    "Your account is waiting for approval from your company's admin. Check back soon.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                    child: Text('Log out', style: TextStyle(color: colors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
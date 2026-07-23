import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/passenger/passenger_home.dart';
import 'theme/app_theme.dart';
import 'screens/admin/create_company_screen.dart';
import 'screens/conductor/conductor_shell.dart';
import 'screens/conductor/pending_approval_screen.dart';
import 'screens/admin/admin_shell.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://stfmxdhrijdezwxbpxlr.supabase.co',
    publishableKey: 'sb_publishable_VLRPU3TJ8rDeSb0S6MIRMQ_ua5y61dP',
  );

  runApp(const ParkPassApp());
}

class ParkPassApp extends StatelessWidget {
  const ParkPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkPass',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

// This widget decides what to show based on login state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) return const LoginScreen();

        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthService().getCurrentUserProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    profileSnapshot.error.toString(),
                  ),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error loading profile: ${profileSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            final profile = profileSnapshot.data;
            if (profile == null) return const LoginScreen();

            final role = profile['role'] as String?;
            final companyId = profile['company_id'] as String?;
            final approvalStatus = profile['approval_status'] as String?;

            if (role == 'admin') {
              return companyId == null
                  ? const CreateCompanyScreen()
                  : AdminShell(companyId: companyId);
            } else if (role == 'conductor') {
              return approvalStatus == 'approved'
                  ? const ConductorShell()
                  : const PendingApprovalScreen();
            } else if (role == 'passenger') {
              return const PassengerHome();
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
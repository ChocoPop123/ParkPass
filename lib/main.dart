import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/passenger/passenger_home.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_controller.dart';
import 'screens/admin/create_company_screen.dart';
import 'screens/conductor/conductor_shell.dart';
import 'screens/conductor/pending_approval_screen.dart';
import 'screens/admin/admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ParkPassApp());
}

class ParkPassApp extends StatefulWidget {
  const ParkPassApp({super.key});

  @override
  State<ParkPassApp> createState() => _ParkPassAppState();
}

class _ParkPassAppState extends State<ParkPassApp> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await Supabase.initialize(
        url: 'https://stfmxdhrijdezwxbpxlr.supabase.co',
        publishableKey: 'sb_publishable_VLRPU3TJ8rDeSb0S6MIRMQ_ua5y61dP',
      );
      await ThemeModeController.instance.load();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Startup error: $_error')),
        ),
      );
    }

    if (!_ready) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeModeController.instance,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'ParkPass',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const AuthGate(),
        );
      },
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
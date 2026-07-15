


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/passenger/passenger_home.dart';
import 'screens/conductor/conductor_home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://stfmxdhrijdezwxbpxlr.supabase.co',
    anonKey:'sb_publishable_VLRPU3TJ8rDeSb0S6MIRMQ_ua5y61dP',

    
  );

  runApp(const ParkPassApp());
}

class ParkPassApp extends StatelessWidget {
  const ParkPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkPass',
      theme: ThemeData(primarySwatch: Colors.blue),
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

        if (session == null) {
          return const LoginScreen();
        }

        // Logged in — figure out the role, then show the right home screen.
        return FutureBuilder<String?>(
          future: AuthService().getCurrentUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final role = roleSnapshot.data;
            if (role == 'conductor') {
              return const ConductorHome();
            } else if (role == 'passenger') {
              return const PassengerHome();
            } else {
              // Something went wrong (no profile row found)
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
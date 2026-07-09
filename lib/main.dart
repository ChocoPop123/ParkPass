import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'stfmxdhrijdezwxbpxlr',
    anonKey: 'sb_publishable_VLRPU3TJ8rDeSb0S6MIRMQ_ua5y61dP',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkPass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'ParkPass Connected to Supabase 🚍',
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}

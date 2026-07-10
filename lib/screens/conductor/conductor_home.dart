import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConductorHome extends StatelessWidget {
  const ConductorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductor Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: const Center(child: Text('Welcome, conductor! Routes coming in Part 5.')),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/company_model.dart';
import '../../widgets/company_picker_sheet.dart';
import '../../widgets/glass_widgets.dart';

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  CompanyModel? _selectedCompany;

  Future<void> _openPicker() async {
    final result = await showCompanyPicker(context);
    setState(() => _selectedCompany = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ParkPass', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassSelectorChip(
                icon: Icons.directions_bus,
                label: _selectedCompany?.name ?? 'All Companies',
                onTap: _openPicker,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GlassPanel(
                  child: Center(
                    child: Text(
                      'Trips for ${_selectedCompany?.name ?? "all companies"}\ncoming in Part 6.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
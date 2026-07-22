import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int _currentIndex = 0;

  String? _origin;
  String? _destination;
  DateTime? _selectedDate;

  Future<void> _openPicker() async {
    final result = await showCompanyPicker(context);

    if (result != null) {
      setState(() => _selectedCompany = result);
    }
  }

  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break;

      case 1:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const SearchRoutesScreen(),
        //   ),
        // );
        break;

      case 2:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const MyTicketsScreen(),
        //   ),
        // );
        break;

      case 3:
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => const PassengerProfileScreen(),
        //   ),
        // );
        break;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: _onNavTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: "Search",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_rounded),
                label: "Tickets",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ParkPass",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            Supabase.instance.client.auth.signOut(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Where would you like to travel today?",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// COMPANY PICKER
                  GlassSelectorChip(
                    icon: Icons.directions_bus_rounded,
                    label: _selectedCompany?.name ?? "All Bus Companies",
                    onTap: _openPicker,
                  ),

                  const SizedBox(height: 24),

                  /// SEARCH CARD
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Search Trips",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInfoTile(
                            Icons.location_on,
                            "From",
                            _origin ?? "Select Departure",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("From tapped"),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildInfoTile(
                            Icons.flag,
                            "To",
                            _destination ?? "Select Destination",
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Destination tapped"),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          _buildInfoTile(
                            Icons.calendar_today,
                            "Departure Date",
                            _selectedDate == null
                                ? "Choose Date"
                                : DateFormat('dd MMM, yyyy')
                                    .format(_selectedDate!),
                            _selectDate,
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Handle search
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F80ED),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                "Search Trips",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Popular Routes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _routeCard("Kampala", "Jinja"),
                  const SizedBox(height: 12),

                  _routeCard("Kampala", "Mbarara"),
                  const SizedBox(height: 12),

                  _routeCard("Kampala", "Gulu"),
                  const SizedBox(height: 12),

                  _routeCard("Kampala", "Mbale"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _routeCard(String from, String to) {
    return GlassPanel(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2F80ED),
          child: Icon(
            Icons.directions_bus,
            color: Colors.white,
          ),
        ),
        title: Text(
          "$from → $to",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          "Daily departures available",
          style: TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 18,
        ),
      ),
    );
  }
}

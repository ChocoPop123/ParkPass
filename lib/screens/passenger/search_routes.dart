import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';
import '../seat_selection_screen.dart';

class SearchRoutesScreen extends StatefulWidget {
  const SearchRoutesScreen({super.key});

  @override
  State<SearchRoutesScreen> createState() => _SearchRoutesScreenState();
}

class _SearchRoutesScreenState extends State<SearchRoutesScreen> {
  String? fromCity;
  String? toCity;
  DateTime? selectedDate;

  Future<List<Map<String, dynamic>>>? _tripResults;
  bool _hasSearched = false;
  bool isLoading = false;
  final TripService _tripService = TripService();

  void _showCityPicker({required bool isDeparture}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isDeparture ? 'Select Departure City' : 'Select Destination City',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: ugandaCities.length,
                  itemBuilder: (context, index) {
                    final city = ugandaCities[index];
                    return ListTile(
                      title: Text(
                        city,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () {
                        setState(() {
                          if (isDeparture) {
                            fromCity = city;
                          } else {
                            toCity = city;
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchTrips() async {
    if (fromCity == null || toCity == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select origin, destination, and date')),
      );
      return;
    }

    setState(() {
      _hasSearched = true;
      isLoading = true;
      _tripResults = _tripService.searchTrips(
        origin: fromCity!,
        destination: toCity!,
        date: selectedDate!,
      );
    });

    try {
      await _tripResults;
    } catch (e) {
      // Error handled by FutureBuilder
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          children: [
            // Header Section
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Search Trips",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Find your next journey",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Form
            GlassPanel(
              child: Column(
                children: [
                  _buildInputCard(
                    icon: Icons.location_on,
                    label: 'From',
                    value: fromCity ?? 'Select Departure',
                    onTap: () => _showCityPicker(isDeparture: true),
                  ),
                  Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.swap_vert_circle,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          final temp = fromCity;
                          fromCity = toCity;
                          toCity = temp;
                        });
                      },
                    ),
                  ),
                  _buildInputCard(
                    icon: Icons.flag,
                    label: 'To',
                    value: toCity ?? 'Select Destination',
                    onTap: () => _showCityPicker(isDeparture: false),
                  ),
                  const SizedBox(height: 12),
                  GlassSelectorChip(
                    icon: Icons.calendar_today,
                    label: selectedDate == null
                        ? 'Choose Date'
                        : DateFormat('dd MMM yyyy').format(selectedDate!),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark(),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassGradientButton(
              label: "Search Trips",
              onTap: _searchTrips,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),

            // Results Section
            if (_hasSearched)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _tripResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: kAuthAccentBlue),
                          SizedBox(height: 16),
                          Text(
                            "Searching for best routes...",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        'Error loading trips: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bus_alert_rounded,
                              color: Colors.white24, size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No trips found for this route and date.',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final trips = snapshot.data!;
                  return Column(
                    children: trips.map((trip) => _buildTripCard(trip)).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final departureTime = DateTime.parse(trip['departure_time']);
    final formattedTime = DateFormat('hh:mm a').format(departureTime);
    final busClass = trip['bus_class'] ?? 'Ordinary';
    final plate = trip['bus_number_plate'] ?? '—';
    final fare = trip['fare_override'] ?? trip['routes']['base_fare'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kAuthAccentBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_bus,
                      color: kAuthAccentBlue, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "$busClass",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildClassBadge(busClass),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Plate: $plate • $formattedTime",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kAuthAccentGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: kAuthAccentGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "UGX $fare",
                        style: const TextStyle(
                          color: kAuthAccentGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "per seat",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.airline_seat_recline_normal,
                        color: Colors.white38, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${trip['vehicle_seat_count']} Total Seats",
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeatSelectionScreen(
                          tripId: trip['id'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAuthAccentBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassBadge(String busClass) {
    Color color = Colors.grey;
    if (busClass.toLowerCase().contains('vip')) {
      color = Colors.purpleAccent;
    } else if (busClass.toLowerCase().contains('exec')) {
      color = kAuthAccentBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        "CLASS",
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: value.startsWith('Select') || value == 'Choose Date'
                          ? Colors.white60
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: value.startsWith('Select') || value == 'Choose Date'
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

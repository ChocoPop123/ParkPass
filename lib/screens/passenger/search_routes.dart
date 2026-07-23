import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';
import '../seat_selection_screen.dart';

class SearchRoutesScreen extends StatefulWidget {
  // These allow the Home screen to pass the selected cities and date
  final String? initialOrigin;
  final String? initialDestination;
  final DateTime? initialDate;

  const SearchRoutesScreen({
    super.key,
    this.initialOrigin,
    this.initialDestination,
    this.initialDate,
  });

  @override
  State<SearchRoutesScreen> createState() => _SearchRoutesScreenState();
}

class _SearchRoutesScreenState extends State<SearchRoutesScreen> {
  String? fromCity;
  String? toCity;
  DateTime? selectedDate;

  final TripService _tripService = TripService();

  List<Map<String, dynamic>> trips = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // 1. Grab the data passed from the Passenger Home screen
    fromCity = widget.initialOrigin;
    toCity = widget.initialDestination;
    selectedDate = widget.initialDate;

    // 2. If the user already selected cities, auto-run the search!
    if (fromCity != null && toCity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchTrips();
      });
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showCityPicker({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOrigin ? "Select Origin City" : "Select Destination City",
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
                      leading: const Icon(Icons.location_city, color: Colors.white70),
                      title: Text(
                        city,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          if (isOrigin) {
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

  Future<void> searchTrips() async {
    if (fromCity == null || toCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select origin and destination'),
        ),
      );
      return;
    }

    if (fromCity == toCity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Origin and destination cannot be the same'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 3. Pass the specific date to your updated TripService
      final results = await _tripService.searchTrips(
        origin: fromCity!,
        destination: toCity!,
        date: selectedDate,
      );

      if (!mounted) return;

      setState(() {
        trips = results;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
                const SizedBox(height: 30),
                GlassPanel(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _showCityPicker(isOrigin: true),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "From",
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  Text(
                                    fromCity ?? "Select Departure",
                                    style: TextStyle(
                                      color: fromCity != null ? Colors.white : Colors.white60,
                                      fontSize: 16,
                                      fontWeight: fromCity != null ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _showCityPicker(isOrigin: false),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.flag_rounded,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "To",
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  Text(
                                    toCity ?? "Select Destination",
                                    style: TextStyle(
                                      color: toCity != null ? Colors.white : Colors.white60,
                                      fontSize: 16,
                                      fontWeight: toCity != null ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: pickDate,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Departure Date",
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  Text(
                                    selectedDate == null
                                        ? "Choose Date"
                                        : DateFormat("dd MMM yyyy").format(selectedDate!),
                                    style: TextStyle(
                                      color: selectedDate != null ? Colors.white : Colors.white60,
                                      fontSize: 16,
                                      fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GlassGradientButton(
                        label: "Search Trips",
                        onTap: searchTrips,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (trips.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        "No trips found for this route and date.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.directions_bus),
                            title: Text(
                              "${trip['bus_class'] ?? 'Ordinary'} Bus (${trip['bus_number_plate'] ?? 'No Plate'})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${trip['routes']['origin']} → ${trip['routes']['destination']}\n"
                                  "${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(trip['departure_time']))}",
                            ),
                            trailing: Text(
                              "UGX ${trip['routes']['base_fare']}",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SeatSelectionScreen(
                                    tripId: trip['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
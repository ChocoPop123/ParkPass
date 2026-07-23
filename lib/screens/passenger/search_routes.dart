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

  final TripService _tripService = TripService();

  List<Map<String, dynamic>> trips = [];
  bool isLoading = false;

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
      final results = await _tripService.searchTrips(
        origin: fromCity!,
        destination: toCity!,
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
                      DropdownMenu<String>(
                        width: double.infinity,
                        initialSelection: fromCity,
                        label: const Text("From"),
                        textStyle: const TextStyle(color: Colors.white),
                        dropdownMenuEntries: ugandaCities
                            .map((city) => DropdownMenuEntry(
                                  value: city,
                                  label: city,
                                ))
                            .toList(),
                        onSelected: (value) {
                          setState(() {
                            fromCity = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownMenu<String>(
                        width: double.infinity,
                        initialSelection: toCity,
                        label: const Text("To"),
                        textStyle: const TextStyle(color: Colors.white),
                        dropdownMenuEntries: ugandaCities
                            .map((city) => DropdownMenuEntry(
                                  value: city,
                                  label: city,
                                ))
                            .toList(),
                        onSelected: (value) {
                          setState(() {
                            toCity = value;
                          });
                        },
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
                              Text(
                                selectedDate == null
                                    ? "Select Departure Date"
                                    : DateFormat("dd MMM yyyy")
                                        .format(selectedDate!),
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
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
                        "Search for buses to see available trips.",
                        textAlign: TextAlign.center,
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

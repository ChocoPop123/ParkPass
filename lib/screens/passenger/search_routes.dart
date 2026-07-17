import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../services/trip_service.dart';
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
      appBar: AppBar(
        title: const Text("Search Routes"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: fromCity,
              decoration: const InputDecoration(
                labelText: "From",
                border: OutlineInputBorder(),
              ),
              items: ugandaCities
                  .map(
                    (city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fromCity = value;
                });
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: toCity,
              decoration: const InputDecoration(
                labelText: "To",
                border: OutlineInputBorder(),
              ),
              items: ugandaCities
                  .map(
                    (city) => DropdownMenuItem(
                  value: city,
                  child: Text(city),
                ),
              )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  toCity = value;
                });
              },
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? "Select Date"
                    : DateFormat('dd MMM yyyy').format(selectedDate!),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: searchTrips,
                child: const Text("Search Buses"),
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
                          trip['buses']['bus_name'],
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
    );
  }
}
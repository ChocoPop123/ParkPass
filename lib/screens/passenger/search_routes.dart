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
  DateTime? returnDate;
  bool isRoundTrip = false;

  Future<List<Map<String, dynamic>>>? _outboundResults;
  Future<List<Map<String, dynamic>>>? _returnResults;
  
  bool _hasSearched = false;
  bool isLoading = false;
  final TripService _tripService = TripService();

  void _showCityPicker({required bool isDeparture}) {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
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
                style: TextStyle(
                  color: colors.textPrimary,
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
                        style: TextStyle(color: colors.textPrimary, fontSize: 16),
                      ),
                      trailing: Icon(Icons.chevron_right, color: colors.textSecondary),
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

    if (isRoundTrip && returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a return date')),
      );
      return;
    }

    setState(() {
      _hasSearched = true;
      isLoading = true;
      
      _outboundResults = _tripService.searchTrips(
        origin: fromCity!,
        destination: toCity!,
        date: selectedDate!,
      );

      if (isRoundTrip) {
        _returnResults = _tripService.searchTrips(
          origin: toCity!, 
          destination: fromCity!,
          date: returnDate!,
        );
      } else {
        _returnResults = null;
      }
    });

    try {
      await _outboundResults;
      if (isRoundTrip) await _returnResults;
    } catch (e) {
      debugPrint('Search error: $e');
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
    final colors = AppColors.of(context);
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Text(
          "Search Trips",
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Find your next journey in Uganda",
          style: TextStyle(color: colors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),

        _buildTripTypeToggle(colors),
        const SizedBox(height: 16),

        GlassPanel(
          child: Column(
            children: [
              _buildInputCard(
                icon: Icons.location_on,
                label: 'From',
                value: fromCity ?? 'Select Departure',
                onTap: () => _showCityPicker(isDeparture: true),
                colors: colors,
              ),
              IconButton(
                icon: Icon(Icons.swap_vert_circle, size: 32, color: colors.accent),
                onPressed: () {
                  setState(() {
                    final temp = fromCity;
                    fromCity = toCity;
                    toCity = temp;
                  });
                },
              ),
              _buildInputCard(
                icon: Icons.flag,
                label: 'To',
                value: toCity ?? 'Select Destination',
                onTap: () => _showCityPicker(isDeparture: false),
                colors: colors,
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: GlassSelectorChip(
                      icon: Icons.calendar_today,
                      label: selectedDate == null
                          ? 'Departure'
                          : DateFormat('dd MMM').format(selectedDate!),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ),
                  if (isRoundTrip) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: GlassSelectorChip(
                        icon: Icons.event_repeat,
                        label: returnDate == null
                            ? 'Return'
                            : DateFormat('dd MMM').format(returnDate!),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: returnDate ?? (selectedDate ?? DateTime.now()),
                            firstDate: selectedDate ?? DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => returnDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassGradientButton(
          label: "Search Available Trips",
          onTap: _searchTrips,
          isLoading: isLoading,
        ),
        const SizedBox(height: 32),

        if (_hasSearched) ...[
          _buildResultsList(title: "Outgoing Journeys", results: _outboundResults, colors: colors),
          if (isRoundTrip) ...[
            const SizedBox(height: 32),
            _buildResultsList(title: "Return Journeys", results: _returnResults, colors: colors),
          ],
        ],
      ],
    );
  }

  Widget _buildResultsList({
    required String title,
    required Future<List<Map<String, dynamic>>>? results,
    required AppColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: results,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text("Search failed: ${snapshot.error}", style: TextStyle(color: colors.danger));
            }
            final trips = snapshot.data ?? [];
            if (trips.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text("No trips found for this day.", style: TextStyle(color: colors.textSecondary)),
                ),
              );
            }
            return Column(children: trips.map((t) => _buildTripCard(t, colors)).toList());
          },
        ),
      ],
    );
  }

  Widget _buildTripTypeToggle(AppColors colors) {
    return Row(
      children: [
        _tripTypeButton(label: 'One Way', selected: !isRoundTrip, onTap: () => setState(() => isRoundTrip = false), colors: colors),
        const SizedBox(width: 12),
        _tripTypeButton(label: 'Round Trip', selected: isRoundTrip, onTap: () => setState(() => isRoundTrip = true), colors: colors),
      ],
    );
  }

  Widget _tripTypeButton({required String label, required bool selected, required VoidCallback onTap, required AppColors colors}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? colors.accent : colors.border),
        ),
        child: Text(label, style: TextStyle(color: selected ? colors.buttonText : colors.textSecondary, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, AppColors colors) {
    final departureTime = DateTime.parse(trip['departure_time']);
    final formattedTime = DateFormat('hh:mm a').format(departureTime);
    final busClass = trip['bus_class'] ?? 'Ordinary';
    final plate = trip['bus_number_plate'] ?? '—';
    
    String companyName = 'Unknown';
    try {
      final routes = trip['routes'];
      if (routes != null) {
        final companies = routes['companies'];
        if (companies is Map) {
          companyName = companies['name'] ?? companyName;
        } else if (companies is List && companies.isNotEmpty) {
          companyName = companies[0]['name'] ?? companyName;
        }
      }
    } catch (_) {}
    
    final fare = trip['fare_override'] ?? trip['routes']['base_fare'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus, color: colors.accent, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(companyName, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text("$busClass • $plate • $formattedTime", style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Text("UGX $fare", style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          GlassGradientButton(
            label: "Book Now",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => SeatSelectionScreen(tripId: trip['id'])));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({required IconData icon, required String label, required String value, required VoidCallback onTap, required AppColors colors}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.neutralBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

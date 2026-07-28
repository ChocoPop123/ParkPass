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

  Future<List<Map<String, dynamic>>>? _tripResults;
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
    final colors = AppColors.of(context);
    
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
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        "Find your next journey",
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Round Trip / One Way Toggle
            _buildTripTypeToggle(colors),
            const SizedBox(height: 16),

            // Search Form
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
                  Center(
                    child: IconButton(
                      icon: Icon(
                        Icons.swap_vert_circle,
                        size: 32,
                        color: colors.accent,
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
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) => Theme(
                                data: Theme.of(context).brightness == Brightness.dark 
                                    ? ThemeData.dark() 
                                    : ThemeData.light(), 
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                                if (returnDate != null && returnDate!.isBefore(picked)) {
                                  returnDate = null;
                                }
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
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).brightness == Brightness.dark 
                                    ? ThemeData.dark() 
                                    : ThemeData.light(), 
                                  child: child!,
                                ),
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: colors.accent),
                          const SizedBox(height: 16),
                          Text(
                            "Searching for best routes...",
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, color: colors.danger, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'Error loading trips:\n${snapshot.error}',
                              style: TextStyle(color: colors.danger),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bus_alert_rounded,
                              color: colors.textSecondary.withValues(alpha: 0.3), size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'No trips found for this route and date.',
                            style: TextStyle(color: colors.textSecondary, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final trips = snapshot.data!;
                  return Column(
                    children: trips.map((trip) => _buildTripCard(trip, colors)).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripTypeToggle(AppColors colors) {
    return Row(
      children: [
        _tripTypeButton(
          label: 'One Way', 
          selected: !isRoundTrip, 
          onTap: () => setState(() => isRoundTrip = false),
          colors: colors,
        ),
        const SizedBox(width: 12),
        _tripTypeButton(
          label: 'Round Trip', 
          selected: isRoundTrip, 
          onTap: () => setState(() => isRoundTrip = true),
          colors: colors,
        ),
      ],
    );
  }

  Widget _tripTypeButton({
    required String label, 
    required bool selected, 
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? colors.accent : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.buttonText : colors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, AppColors colors) {
    final departureTime = DateTime.parse(trip['departure_time']);
    final formattedTime = DateFormat('hh:mm a').format(departureTime);
    final busClass = trip['bus_class'] ?? 'Ordinary';
    final plate = trip['bus_number_plate'] ?? '—';
    
    // Safely extract company name
    String companyName = 'Unknown';
    final nestedRoute = trip['routes'];
    if (nestedRoute != null && nestedRoute['companies'] != null) {
      final compData = nestedRoute['companies'];
      if (compData is Map) {
        companyName = compData['name'] ?? 'Unknown';
      } else if (compData is List && compData.isNotEmpty) {
        companyName = compData[0]['name'] ?? 'Unknown';
      }
    }

    final fare = trip['fare_override'] ?? trip['routes']['base_fare'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_bus,
                      color: colors.accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            "$busClass",
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildClassBadge(busClass, colors),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Plate: $plate • $formattedTime",
                        style: TextStyle(
                          color: colors.textSecondary,
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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "UGX $fare",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "per seat",
                        style: TextStyle(
                          color: colors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.neutralBorder, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.airline_seat_recline_normal,
                        color: colors.textSecondary.withValues(alpha: 0.6), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${trip['vehicle_seat_count']} Total Seats",
                      style:
                          TextStyle(color: colors.textSecondary.withValues(alpha: 0.6), fontSize: 13),
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
                    backgroundColor: colors.accent,
                    foregroundColor: colors.buttonText,
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

  Widget _buildClassBadge(String busClass, AppColors colors) {
    Color color = Colors.grey;
    if (busClass.toLowerCase().contains('vip')) {
      color = Colors.purpleAccent;
    } else if (busClass.toLowerCase().contains('exec')) {
      color = colors.accent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
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
    required AppColors colors,
  }) {
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
                  Text(
                    label,
                    style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: value.startsWith('Select') || value == 'Departure' || value == 'Return'
                          ? colors.textSecondary
                          : colors.textPrimary,
                      fontSize: 16,
                      fontWeight: value.startsWith('Select') || value == 'Departure' || value == 'Return'
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

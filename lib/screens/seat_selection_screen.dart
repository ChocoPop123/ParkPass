import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/glass_widgets.dart';
import 'passenger/payment_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String tripId;

  const SeatSelectionScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> seats = [];
  bool isLoading = true;
  String? selectedSeatLabel;
  int? selectedSeatDbNumber;
  double tripFare = 25000.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final tripData = await supabase
          .from('trips')
          .select('fare_override, routes(base_fare)')
          .eq('id', widget.tripId)
          .single();

      final double? fareOverride = tripData['fare_override'] as double?;
      final double baseFare = (tripData['routes']['base_fare'] as num).toDouble();
      tripFare = fareOverride ?? baseFare;

      final seatsData = await supabase
          .from('seats')
          .select()
          .eq('trip_id', widget.tripId)
          .order('seat_number', ascending: true);

      setState(() {
        seats = List<Map<String, dynamic>>.from(seatsData);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    // Grid structure: 2 seats, 1 aisle, 2 seats (5 columns total)
    const int crossAxisCount = 5;
    final int gridItemCount = isLoading ? 0 : ((seats.length / 4).ceil() * 5);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Select Seat",
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Bus Map Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem("Available", Colors.green.withValues(alpha: 0.7), colors),
                    _buildLegendItem("Selected", colors.accent, colors),
                    _buildLegendItem("Occupied", colors.danger.withValues(alpha: 0.4), colors),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Bus Interior Body
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.accent))
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.3),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(50), bottom: Radius.circular(20)),
                          border: Border.all(color: colors.neutralBorder, width: 2),
                        ),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: gridItemCount,
                          itemBuilder: (context, index) {
                            final int row = index ~/ crossAxisCount;
                            final int col = index % crossAxisCount;

                            // Col 2 is the aisle
                            if (col == 2) return const SizedBox.shrink();

                            // Map grid index to seat list index (ignoring aisle)
                            final int seatListIndex = (row * 4) + (col < 2 ? col : col - 1);
                            
                            if (seatListIndex >= seats.length) return const SizedBox.shrink();

                            final seat = seats[seatListIndex];
                            final status = seat['status'];
                            final int dbNumber = seat['seat_number'];
                            
                            // Visual label: A1, A2, B1, B2...
                            final String rowLetter = String.fromCharCode(65 + row);
                            final String seatLabel = "$rowLetter${(col < 2 ? col + 1 : col)}";

                            return _BusSeat(
                              label: seatLabel,
                              status: status,
                              isSelected: selectedSeatLabel == seatLabel,
                              onTap: () {
                                setState(() {
                                  selectedSeatLabel = seatLabel;
                                  selectedSeatDbNumber = dbNumber;
                                });
                              },
                              colors: colors,
                            );
                          },
                        ),
                      ),
              ),

              // Bottom Summary and Button
              if (selectedSeatLabel != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Selected Seat", style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                                Text("Seat $selectedSeatLabel", style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Total Price", style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                                Text("UGX ${tripFare.toStringAsFixed(0)}", style: TextStyle(color: colors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GlassGradientButton(
                          label: "Confirm & Pay",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  tripId: widget.tripId,
                                  seatLabel: selectedSeatLabel!,
                                  seatNumberInt: selectedSeatDbNumber!,
                                  amount: tripFare,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, AppColors colors) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _BusSeat extends StatelessWidget {
  final String label;
  final String status;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  const _BusSeat({
    required this.label,
    required this.status,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = status == 'available';
    
    Color seatColor;
    if (!isAvailable) {
      seatColor = colors.danger.withValues(alpha: 0.3);
    } else if (isSelected) {
      seatColor = colors.accent;
    } else {
      seatColor = Colors.green.withValues(alpha: 0.6);
    }

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Seat Back
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: seatColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.circular(4)),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(color: colors.accent.withValues(alpha: 0.4), blurRadius: 8, spreadRadius: 1)
                    ],
                  ),
                ),
                // Headrest detail
                Positioned(
                  top: 4,
                  child: Container(
                    width: 20,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: isAvailable ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Seat Cushion (Cushion look)
          Container(
            height: 4,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: seatColor.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}

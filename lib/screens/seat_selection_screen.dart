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
  double tripFare = 25000.0; // Fallback default fare

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // 1. Fetch trip and route details to get the correct fare
      final tripData = await supabase
          .from('trips')
          .select('fare_override, routes(base_fare)')
          .eq('id', widget.tripId)
          .single();

      final double? fareOverride = tripData['fare_override'] as double?;
      final double baseFare = (tripData['routes']['base_fare'] as num).toDouble();

      tripFare = fareOverride ?? baseFare;

      // 2. Fetch seats for this trip
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
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                    const Text(
                      "Choose Your Seat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Driver Indicator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Text(
                      "DRIVER",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Seats Grid Container
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : seats.isEmpty
                      ? const Center(
                    child: Text(
                      "No seats available for this trip.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                      : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: seats.length,
                    itemBuilder: (context, index) {
                      final seat = seats[index];
                      final status = seat['status'];
                      final int dbSeatNumber = seat['seat_number'];

                      // Compute Alphanumeric Label (e.g., A1, A2, B1, B2) based on 5 columns
                      final int rowIndex = index ~/ 5;
                      final int colIndex = (index % 5) + 1;
                      final String rowLetter = String.fromCharCode(65 + rowIndex); // 'A', 'B', etc.
                      final String seatLabel = "$rowLetter$colIndex";

                      final isAvailable = status == 'available';
                      final isSelected = selectedSeatLabel == seatLabel;

                      Color bgColor;
                      if (!isAvailable) {
                        bgColor = Colors.redAccent;
                      } else if (isSelected) {
                        bgColor = const Color(0xFF2F80ED);
                      } else {
                        bgColor = Colors.green;
                      }

                      return GestureDetector(
                        onTap: isAvailable
                            ? () {
                          setState(() {
                            selectedSeatLabel = seatLabel;
                            selectedSeatDbNumber = dbSeatNumber;
                          });
                        }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            seatLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Action Bar when a seat is chosen
                if (selectedSeatLabel != null && selectedSeatDbNumber != null) ...[
                  const SizedBox(height: 20),
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Selected Seat",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Seat $selectedSeatLabel",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Fare",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "UGX $tripFare",
                                style: const TextStyle(
                                  color: Color(0xFF2F80ED),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GlassGradientButton(
                            label: "Proceed to Payment",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
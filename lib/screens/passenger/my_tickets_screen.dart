import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_widgets.dart';
import 'ticket_confirmation_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> myBookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTickets();
  }

  Future<void> _fetchMyTickets() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final data = await supabase
          .from('bookings')
          .select('*, trips(*, routes(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        myBookings = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tickets: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "My Tickets",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : myBookings.isEmpty
                      ? const Center(
                          child: Text(
                            "You haven't booked any trips yet.",
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: myBookings.length,
                          itemBuilder: (context, index) {
                            final booking = myBookings[index];
                            final trip = booking['trips'];
                            final route = trip['routes'];
                            final departureTime = DateTime.parse(trip['departure_time']);
                            final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(departureTime);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GlassPanel(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketConfirmationScreen(
                                          bookingId: booking['id'],
                                          seatLabel: "Seat ${booking['seat_number']}",
                                          tripId: trip['id'],
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "${route['origin']} → ${route['destination']}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: booking['status'] == 'confirmed'
                                                    ? Colors.green.withValues(alpha: 0.2)
                                                    : Colors.orange.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: booking['status'] == 'confirmed'
                                                      ? Colors.green
                                                      : Colors.orange,
                                                ),
                                              ),
                                              child: Text(
                                                (booking['status'] ?? 'confirmed').toUpperCase(),
                                                style: TextStyle(
                                                  color: booking['status'] == 'confirmed'
                                                      ? Colors.greenAccent
                                                      : Colors.orangeAccent,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Date: $formattedDate",
                                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                            Text("Seat: ${booking['seat_number']}",
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Bus Class: ${trip['bus_class']}",
                                                style: const TextStyle(color: Colors.white60, fontSize: 12)),
                                            const Text(
                                              "Tap to view QR Code →",
                                              style: TextStyle(
                                                  color: Color(0xFF2F80ED), fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

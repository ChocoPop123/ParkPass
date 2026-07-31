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
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }
      
      final userId = user.id;
      final data = await supabase
          .from('bookings')
          .select('*, trips(*, routes(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          myBookings = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading tickets: $e');
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tickets: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return RefreshIndicator(
      onRefresh: _fetchMyTickets,
      color: colors.accent,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "My Tickets",
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(child: CircularProgressIndicator(color: colors.accent)),
            )
          else if (myBookings.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 64, color: colors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      "You haven't booked any trips yet.",
                      style: TextStyle(color: colors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ...myBookings.map((booking) {
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
                              Expanded(
                                child: Text(
                                  "${route['origin']} → ${route['destination']}",
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: booking['status'] == 'confirmed'
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
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
                                        ? Colors.green
                                        : Colors.orange,
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
                                  style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                              Text("Seat: ${booking['seat_number']}",
                                  style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Bus Class: ${trip['bus_class']}",
                                  style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.8), fontSize: 12)),
                              Text(
                                "Tap to view QR Code →",
                                style: TextStyle(
                                    color: colors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

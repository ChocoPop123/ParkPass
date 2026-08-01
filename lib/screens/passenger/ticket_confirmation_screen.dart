import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_widgets.dart';
import 'passenger_home.dart';
import 'dart:convert';

class TicketConfirmationScreen extends StatefulWidget {
  final String bookingId;
  final String passengerName;
  final String route;
  final String seatLabel;
  final String tripId;
  final String tripDate;

  const TicketConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.passengerName,
    required this.route,
    required this.seatLabel,
    required this.tripId,
    required this.tripDate,
  });

  @override
  State<TicketConfirmationScreen> createState() => _TicketConfirmationScreenState();
}

class _TicketConfirmationScreenState extends State<TicketConfirmationScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? ticketData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    try {
      final data = await supabase
          .from('bookings')
          .select('*, trips(*, routes(*))')
          .eq('id', widget.bookingId)
          .single();

      setState(() {
        ticketData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ticket: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: colors.accent))
                : ticketData == null
                ? Center(
              child: Text(
                "Ticket details not found.",
                style: TextStyle(color: colors.textSecondary),
              ),
            )
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.greenAccent,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Booking Successful!",
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Your ticket has been generated and confirmed.",
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Ticket Card with GlassPanel
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Route Header
                          Text(
                            "${ticketData!['trips']['routes']['origin']} → ${ticketData!['trips']['routes']['destination']}",
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: colors.neutralBorder),
                          const SizedBox(height: 20),

                          // Details Row 1
                          _buildDetailRow(
                            "Bus Class",
                            ticketData!['trips']['bus_class'] ?? 'Ordinary',
                            "Number Plate",
                            ticketData!['trips']['bus_number_plate'] ?? 'N/A',
                            colors,
                          ),
                          const SizedBox(height: 16),

                          // Details Row 2
                          _buildDetailRow(
                            "Seat Number",
                            widget.seatLabel,
                            "Amount Paid",
                            "UGX ${ticketData!['amount_paid']}",
                            colors,
                          ),
                          const SizedBox(height: 16),

                          // Details Row 3
                          _buildDetailRow(
                            "Departure Time",
                            DateFormat('dd MMM yyyy, hh:mm a').format(
                              DateTime.parse(ticketData!['trips']['departure_time']),
                            ),
                            "Status",
                            ticketData!['status'].toUpperCase(),
                            colors,
                          ),

                          const SizedBox(height: 30),

                          // QR Code Container (White background so scanner reads it instantly)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: jsonEncode({
                                'bookingId': widget.bookingId,
                                'name': widget.passengerName,
                                'route': widget.route,
                                'seat':widget.seatLabel,
                                'date':widget.tripDate
                              }).

                              version: QrVersions.auto,
                              size: 180.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Show this QR code to the conductor at boarding",
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  GlassGradientButton(
                    label: "Back to Home",
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PassengerHome(),
                        ),
                            (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label1, String val1, String label2, String val2, AppColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label1, style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
            const SizedBox(height: 2),
            Text(val1, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label2, style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.6), fontSize: 12)),
            const SizedBox(height: 2),
            Text(val2, style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

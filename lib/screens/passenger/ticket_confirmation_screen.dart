import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_widgets.dart';
import 'passenger_home.dart';

class TicketConfirmationScreen extends StatefulWidget {
  final String bookingId;
  final String seatLabel;
  final String tripId;

  const TicketConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.seatLabel,
    required this.tripId,
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
      // Now also pulls the company name via routes -> companies, so both
      // the ticket card and the QR payload can show who the ticket is
      // actually with, not just the route.
      final data = await supabase
          .from('bookings')
          .select('*, trips(*, routes(*, companies(name)))')
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

  String _companyName() {
    final company = ticketData?['trips']?['routes']?['companies'];
    return company?['name'] as String? ?? 'Unknown Company';
  }

  DateTime _departureTime() {
    return DateTime.parse(ticketData!['trips']['departure_time']);
  }

  // Business rule: a ticket is valid for boarding up to 2 hours after the
  // trip's scheduled departure. Adjust this window if a different grace
  // period is wanted.
  DateTime _validUntil() {
    return _departureTime().add(const Duration(hours: 2));
  }

  bool _isPaid() {
    final status = (ticketData?['status'] as String? ?? '').toLowerCase();
    return status == 'paid';
  }

  // Builds the actual data encoded into the QR code. A conductor's scanner
  // should still verify this against the database before checking someone
  // in (never trust a client-supplied QR payload as proof of payment on
  // its own) — but encoding this much directly in the QR means the ticket
  // is still human-readable / diagnosable even from just a raw scan, and
  // gives the conductor's app everything it needs to show a summary
  // immediately without waiting on a second lookup.
  //
  // Plain labeled text instead of JSON, so a raw scan (even from a generic
  // scanner app) shows a readable ticket stub instead of a data dump.
  String _buildQrPayload() {
    final currency = NumberFormat('#,##0', 'en_US');

    final buffer = StringBuffer()
      ..writeln('===== PARKPASS TICKET =====')
      ..writeln(_companyName())
      ..writeln('${ticketData!['trips']['routes']['origin']} → ${ticketData!['trips']['routes']['destination']}')
      ..writeln('----------------------------')
      ..writeln('Seat: ${widget.seatLabel}')
      ..writeln('Bus Class: ${ticketData!['trips']['bus_class'] ?? 'Ordinary'}')
      ..writeln('Plate: ${ticketData!['trips']['bus_number_plate'] ?? 'N/A'}')
      ..writeln('----------------------------')
      ..writeln('Amount Paid: UGX ${currency.format(ticketData!['amount_paid'])}')
      ..writeln('Payment: ${_isPaid() ? 'CONFIRMED' : (ticketData!['status'] as String? ?? 'UNKNOWN').toUpperCase()}')
      ..writeln('----------------------------')
      ..writeln('Departs: ${DateFormat('dd MMM yyyy, hh:mm a').format(_departureTime())}')
      ..writeln('Valid Until: ${DateFormat('dd MMM yyyy, hh:mm a').format(_validUntil())}')
      ..writeln('----------------------------')
      ..writeln('Booking ID: ${widget.bookingId}')
      ..writeln('============================');

    return buffer.toString();
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
                          // Company name
                          Text(
                            _companyName(),
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),

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
                            DateFormat('dd MMM yyyy, hh:mm a').format(_departureTime()),
                            "Status",
                            (ticketData!['status'] as String? ?? '').toUpperCase(),
                            colors,
                          ),
                          const SizedBox(height: 16),

                          // Validity row
                          _buildDetailRow(
                            "Valid Until",
                            DateFormat('dd MMM yyyy, hh:mm a').format(_validUntil()),
                            "Payment",
                            _isPaid() ? 'PAID ✓' : 'NOT PAID',
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
                              data: _buildQrPayload(),
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
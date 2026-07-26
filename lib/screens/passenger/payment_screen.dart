import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/glass_widgets.dart';
import 'ticket_confirmation_screen.dart'; // We will create this next for the QR code

class PaymentScreen extends StatefulWidget {
  final String tripId;
  final String seatLabel; // e.g., "A5"
  final int seatNumberInt; // e.g., 5 (the integer stored in the database)
  final double amount; // Route base fare or fare override

  const PaymentScreen({
    super.key,
    required this.tripId,
    required this.seatLabel,
    required this.seatNumberInt,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final supabase = Supabase.instance.client;

  String paymentMethod = 'mobile_money'; // 'mobile_money' or 'card'
  String telecomProvider = 'MTN'; // 'MTN' or 'Airtel'

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();

  bool isProcessing = false;

  Future<void> _processPayment() async {
    // Basic validation
    if (paymentMethod == 'mobile_money' && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Mobile Money phone number')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final userId = supabase.auth.currentUser!.id;

      // 1. Insert the booking record into Supabase
      final bookingData = await supabase.from('bookings').insert({
        'trip_id': widget.tripId,
        'user_id': userId,
        'seat_number': widget.seatNumberInt,
        'status': 'confirmed',
        'payment_method': paymentMethod,
        'amount_paid': widget.amount,
      }).select().single();

      // 2. Update the seat status to 'booked'
      await supabase
          .from('seats')
          .update({'status': 'booked'})
          .eq('trip_id', widget.tripId)
          .eq('seat_number', widget.seatNumberInt);

      if (!mounted) return;

      // 3. Navigate to Ticket & QR Code Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TicketConfirmationScreen(
            bookingId: bookingData['id'],
            seatLabel: widget.seatLabel,
            tripId: widget.tripId,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
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
            child: SingleChildScrollView(
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
                        "Checkout",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Fare Summary Card
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Booking Summary",
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Selected Seat:", style: TextStyle(color: Colors.white)),
                              Text("Seat ${widget.seatLabel}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total Fare:", style: TextStyle(color: Colors.white)),
                              Text("UGX ${widget.amount}", style: const TextStyle(color: Color(0xFF2F80ED), fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Select Payment Method",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Switcher Tabs
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => paymentMethod = 'mobile_money'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: paymentMethod == 'mobile_money' ? const Color(0xFF2F80ED) : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            alignment: Alignment.center,
                            child: const Text("Mobile Money", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => paymentMethod = 'card'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: paymentMethod == 'card' ? const Color(0xFF2F80ED) : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            alignment: Alignment.center,
                            child: const Text("Bank Card", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Dynamic Form Fields Based on Payment Method
                  GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: paymentMethod == 'mobile_money'
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Choose Network", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("MTN"),
                                selected: telecomProvider == 'MTN',
                                onSelected: (val) => setState(() => telecomProvider = 'MTN'),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text("Airtel"),
                                selected: telecomProvider == 'Airtel',
                                onSelected: (val) => setState(() => telecomProvider = 'Airtel'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text("Phone Number", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "077XXXXXXX / 070XXXXXXX",
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.06),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Card Details", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cardController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "XXXX XXXX XXXX XXXX",
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.06),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  GlassGradientButton(
                    label: isProcessing ? "Processing..." : "Pay UGX ${widget.amount}",
                    onTap: isProcessing ? () {} : _processPayment,
                    isLoading: isProcessing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
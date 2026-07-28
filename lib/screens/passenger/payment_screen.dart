import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/glass_widgets.dart';
import 'ticket_confirmation_screen.dart';

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
    final colors = AppColors.of(context);
    
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
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Checkout",
                        style: TextStyle(
                          color: colors.textPrimary,
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
                          Text(
                            "Booking Summary",
                            style: TextStyle(color: colors.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Selected Seat:", style: TextStyle(color: colors.textPrimary)),
                              Text("Seat ${widget.seatLabel}", style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Fare:", style: TextStyle(color: colors.textPrimary)),
                              Text("UGX ${widget.amount}", style: TextStyle(color: colors.accent, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Select Payment Method",
                    style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
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
                              color: paymentMethod == 'mobile_money' ? colors.accent : colors.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: paymentMethod == 'mobile_money' ? colors.accent : colors.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                                "Mobile Money", 
                                style: TextStyle(
                                    color: paymentMethod == 'mobile_money' ? colors.buttonText : colors.textSecondary, 
                                    fontWeight: FontWeight.bold
                                )
                            ),
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
                              color: paymentMethod == 'card' ? colors.accent : colors.surface.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: paymentMethod == 'card' ? colors.accent : colors.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                                "Bank Card", 
                                style: TextStyle(
                                    color: paymentMethod == 'card' ? colors.buttonText : colors.textSecondary, 
                                    fontWeight: FontWeight.bold
                                )
                            ),
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
                          Text("Choose Network", style: TextStyle(color: colors.textSecondary, fontSize: 14)),
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
                          Text("Phone Number", style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: "077XXXXXXX / 070XXXXXXX",
                              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.4)),
                              filled: true,
                              fillColor: colors.surface.withValues(alpha: 0.5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.neutralBorder)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.neutralBorder)),
                            ),
                          ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Card Details", style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cardController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: "XXXX XXXX XXXX XXXX",
                              hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.4)),
                              filled: true,
                              fillColor: colors.surface.withValues(alpha: 0.5),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.neutralBorder)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: colors.neutralBorder)),
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

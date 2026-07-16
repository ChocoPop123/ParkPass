import 'package:flutter/material.dart';

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
  String? selectedSeat;

  // Sample bus layout (2+3)
  final List<String> seats = [
    "A1","A2","A3","A4","A5",
    "B1","B2","B3","B4","B5",
    "C1","C2","C3","C4","C5",
    "D1","D2","D3","D4","D5",
    "E1","E2","E3","E4","E5",
  ];

  // Example booked seats
  final List<String> bookedSeats = [
    "A4",
    "B2",
    "C5",
    "D3",
    "E1",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Seat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              width: 220,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "DRIVER",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: GridView.builder(
                itemCount: seats.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final seat = seats[index];

                  Color color = Colors.green;

                  if (bookedSeats.contains(seat)) {
                    color = Colors.red;
                  }

                  if (selectedSeat == seat) {
                    color = Colors.blue;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (bookedSeats.contains(seat)) return;

                      setState(() {
                        selectedSeat = seat;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          seat,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (selectedSeat != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Seat $selectedSeat selected!",
                        ),
                      ),
                    );
                  },
                  child: Text("Continue ($selectedSeat)"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
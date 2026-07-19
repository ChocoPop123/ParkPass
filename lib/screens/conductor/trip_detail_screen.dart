import 'package:flutter/material.dart';
import '../../models/trip_model.dart';
import '../../models/booking_model.dart';
import '../../models/cargo_booking_model.dart';
import '../../services/trip_service.dart';
import '../../services/cargo_service.dart';
import '../../widgets/glass_widgets.dart';
import 'create_trip_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final TripModel trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final _tripService = TripService();
  final _cargoService = CargoService();

  late TripModel _trip;
  List<BookingModel> _manifest = [];
  List<CargoBookingModel> _cargo = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final manifest = await _tripService.getManifestForTrip(_trip.id);
      final cargo = await _cargoService.getCargoForTrip(_trip.id);
      setState(() {
        _manifest = manifest;
        _cargo = cargo;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setStatus(String status) async {
    await _tripService.updateTripStatus(_trip.id, status);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF17242A),
        title: const Text('Delete this trip?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B81))),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _tripService.deleteTrip(_trip.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _statusChip(String label, String value) {
    final isActive = _trip.status == value;
    return GestureDetector(
      onTap: () => _setStatus(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kAuthAccentBlue : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeLabel = _trip.routeOrigin != null
        ? '${_trip.routeOrigin} → ${_trip.routeDestination}'
        : 'Trip';

    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(routeLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70),
                    onPressed: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateTripScreen(existingTrip: _trip)),
                      );
                      if (changed == true && mounted) Navigator.pop(context, true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B81)),
                    onPressed: _confirmDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_trip.departureTime.toString().substring(0, 16)} · ${_trip.busClass}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${_trip.busNumberPlate ?? "No plate set"} · ${_trip.busColor ?? "No color set"}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Driver: ${_trip.driverName ?? "—"} · ${_trip.driverContact ?? "—"}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fare: UGX ${_trip.effectiveFare.toStringAsFixed(0)} · Seats: ${_trip.vehicleSeatCount} · Cargo left: ${_trip.remainingCargoKg}kg',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Text('STATUS', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statusChip('Scheduled', 'scheduled'),
                        _statusChip('Delayed', 'delayed'),
                        _statusChip('Cancelled', 'cancelled'),
                        _statusChip('Departed', 'departed'),
                      ],
                    ),
                    if (_trip.isPastDeparture && _trip.status == 'scheduled') ...[
                      const SizedBox(height: 8),
                      Text('Auto-marked as departed (5+ min past departure time)',
                          style: TextStyle(color: kAuthAccentMint.withOpacity(0.8), fontSize: 11)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('PASSENGER MANIFEST', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              GlassPanel(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                    : _manifest.isEmpty
                    ? Text('No bookings yet.', style: TextStyle(color: Colors.white.withOpacity(0.5)))
                    : Column(
                  children: _manifest.map((b) {
                    return GlassListRow(
                      icon: b.checkedIn ? Icons.check_circle : Icons.person_outline,
                      title: b.passengerName ?? 'Passenger',
                      subtitle: 'Seat ${b.seatNumber ?? "?"} · ${b.paymentStatus}${b.checkedIn ? " · Checked in" : ""}',
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text('CARGO BOOKINGS', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              GlassPanel(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
                    : _cargo.isEmpty
                    ? Text('No cargo bookings yet.', style: TextStyle(color: Colors.white.withOpacity(0.5)))
                    : Column(
                  children: _cargo.map((c) {
                    return GlassListRow(
                      icon: Icons.inventory_2_outlined,
                      title: c.ownerName ?? 'Cargo owner',
                      subtitle: '${c.weightKg}kg · UGX ${c.price.toStringAsFixed(0)} · ${c.status}',
                      trailing: c.status == 'pending'
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassIconAction(
                            icon: Icons.check,
                            color: kAuthAccentGreen,
                            onTap: () async {
                              await _cargoService.setCargoStatus(c.id, 'verified');
                              _load();
                            },
                          ),
                          GlassIconAction(
                            icon: Icons.close,
                            color: const Color(0xFFFF6B81),
                            onTap: () async {
                              await _cargoService.setCargoStatus(c.id, 'rejected');
                              _load();
                            },
                          ),
                        ],
                      )
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
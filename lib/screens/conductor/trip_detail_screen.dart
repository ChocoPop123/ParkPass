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
    final colors = AppColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Delete this trip?', style: TextStyle(color: colors.textPrimary)),
        content: Text('This cannot be undone.', style: TextStyle(color: colors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _tripService.deleteTrip(_trip.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  Widget _statusChip(String label, String value, AppColors colors) {
    final isActive = _trip.status == value;
    return GestureDetector(
      onTap: () => _setStatus(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: isActive ? colors.buttonText : colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final routeLabel = _trip.routeOrigin != null
        ? '${_trip.routeOrigin} \u2192 ${_trip.routeDestination}'
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
                    icon: Icon(Icons.arrow_back, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(routeLabel,
                        style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: colors.textSecondary),
                    onPressed: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateTripScreen(existingTrip: _trip)),
                      );
                      if (changed == true && mounted) Navigator.pop(context, true);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colors.danger),
                    onPressed: _confirmDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_trip.departureTime.toString().substring(0, 16)} \u00b7 ${_trip.busClass}',
                        style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      '${_trip.busNumberPlate ?? "No plate set"} \u00b7 ${_trip.busColor ?? "No color set"}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Driver: ${_trip.driverName ?? "\u2014"} \u00b7 ${_trip.driverContact ?? "\u2014"}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fare: UGX ${_trip.effectiveFare.toStringAsFixed(0)} \u00b7 Seats: ${_trip.vehicleSeatCount} \u00b7 Cargo left: ${_trip.remainingCargoKg}kg',
                      style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Text('STATUS', style: TextStyle(color: colors.textSecondary, fontSize: 11, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _statusChip('Scheduled', 'scheduled', colors),
                        _statusChip('Delayed', 'delayed', colors),
                        _statusChip('Cancelled', 'cancelled', colors),
                        _statusChip('Departed', 'departed', colors),
                      ],
                    ),
                    if (_trip.isPastDeparture && _trip.status == 'scheduled') ...[
                      const SizedBox(height: 8),
                      Text('Auto-marked as departed (5+ min past departure time)',
                          style: TextStyle(color: colors.accent, fontSize: 11)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('PASSENGER MANIFEST', style: TextStyle(color: colors.textSecondary, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              GlassPanel(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.accent))
                    : _manifest.isEmpty
                    ? Text('No bookings yet.', style: TextStyle(color: colors.textSecondary))
                    : Column(
                  children: _manifest.map((b) {
                    return GlassListRow(
                      icon: b.checkedIn ? Icons.check_circle : Icons.person_outline,
                      title: b.passengerName ?? 'Passenger',
                      subtitle: 'Seat ${b.seatNumber ?? "?"} \u00b7 ${b.paymentStatus}${b.checkedIn ? " \u00b7 Checked in" : ""}',
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text('CARGO BOOKINGS', style: TextStyle(color: colors.textSecondary, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              GlassPanel(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: colors.accent))
                    : _cargo.isEmpty
                    ? Text('No cargo bookings yet.', style: TextStyle(color: colors.textSecondary))
                    : Column(
                  children: _cargo.map((c) {
                    return GlassListRow(
                      icon: Icons.inventory_2_outlined,
                      title: c.ownerName ?? 'Cargo owner',
                      subtitle: '${c.weightKg}kg \u00b7 UGX ${c.price.toStringAsFixed(0)} \u00b7 ${c.status}',
                      trailing: c.status == 'pending'
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GlassIconAction(
                            icon: Icons.check,
                            color: colors.accent,
                            onTap: () async {
                              await _cargoService.setCargoStatus(c.id, 'verified');
                              _load();
                            },
                          ),
                          GlassIconAction(
                            icon: Icons.close,
                            color: colors.danger,
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
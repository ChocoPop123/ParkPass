import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/route_model.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';

class CreateTripScreen extends StatefulWidget {
  final TripModel? existingTrip;
  const CreateTripScreen({super.key, this.existingTrip});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _tripService = TripService();
  late final TextEditingController _seatCountController;
  late final TextEditingController _maxCargoController;

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  DateTime? _selectedDateTime;
  bool _isLoading = false;
  bool _isLoadingRoutes = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _seatCountController = TextEditingController(
        text: widget.existingTrip?.vehicleSeatCount.toString() ?? '14');
    _maxCargoController = TextEditingController(
        text: widget.existingTrip?.maxCargoKg.toString() ?? '100');
    _selectedDateTime = widget.existingTrip?.departureTime;

    _loadRoutes();
  }

  @override
  void dispose() {
    _seatCountController.dispose();
    _maxCargoController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    final routes = await _tripService.getAllRoutes();
    setState(() {
      _routes = routes;
      _isLoadingRoutes = false;

      if (widget.existingTrip != null) {
        try {
          _selectedRoute = routes.firstWhere(
              (r) => r.id == widget.existingTrip!.routeId);
        } catch (_) {}
      }
    });
  }

  Future<void> _pickDateTime() async {
    final initialDate = _selectedDateTime ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(DateTime.now()) ? DateTime.now() : initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow some buffer for historical edits if needed
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  Future<void> _handleCreate() async {
    if (_selectedRoute == null || _selectedDateTime == null) {
      setState(() => _errorMessage = 'Pick a route and a departure time.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.existingTrip != null) {
        await _tripService.updateTrip(
          tripId: widget.existingTrip!.id,
          routeId: _selectedRoute!.id,
          departureTime: _selectedDateTime!,
          seatCount: int.parse(_seatCountController.text.trim()),
          maxCargoKg: double.parse(_maxCargoController.text.trim()),
        );
      } else {
        await _tripService.createTrip(
          routeId: _selectedRoute!.id,
          departureTime: _selectedDateTime!,
          seatCount: int.parse(_seatCountController.text.trim()),
          maxCargoKg: double.parse(_maxCargoController.text.trim()),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTrip != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: SafeArea(
          child: _isLoadingRoutes
              ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isEditing ? "Update Trip" : "Schedule Trip",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEditing ? "Update journey details" : "Create a new journey for passengers",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                const AuthFieldLabel('ROUTE'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RouteModel>(
                      isExpanded: true,
                      dropdownColor: const Color(0xFF17242A),
                      value: _selectedRoute,
                      hint: Text(
                        'Select a route',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: _routes.map((route) {
                        return DropdownMenuItem(
                          value: route,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${route.origin} → ${route.destination}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "UGX ${route.baseFare.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedRoute = value),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const AuthFieldLabel('NUMBER OF SEATS'),
                const SizedBox(height: 8),
                GlassTextField(
                  controller: _seatCountController,
                  hint: '14',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                const AuthFieldLabel('MAX CARGO CAPACITY (KG)'),
                const SizedBox(height: 8),
                GlassTextField(
                  controller: _maxCargoController,
                  hint: '100',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                const AuthFieldLabel('DEPARTURE TIME'),
                const SizedBox(height: 8),
                GlassSelectorChip(
                  icon: Icons.calendar_today,
                  label: _selectedDateTime == null
                      ? 'Pick departure date & time'
                      : DateFormat('dd MMM yyyy, hh:mm a').format(_selectedDateTime!),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null) AuthErrorText(_errorMessage!),
                GlassGradientButton(
                  label: isEditing ? 'Update Trip' : 'Create Trip',
                  isLoading: _isLoading,
                  onTap: _handleCreate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
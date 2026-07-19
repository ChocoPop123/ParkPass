import 'package:flutter/material.dart';
import '../../models/route_model.dart';
import '../../services/trip_service.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/trip_model.dart';

class CreateTripScreen extends StatefulWidget {
  final TripModel? existingTrip;
  const CreateTripScreen({super.key, this.existingTrip});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _tripService = TripService();
  final _seatCountController = TextEditingController(text: '14');
  final _maxCargoController = TextEditingController(text: '100');
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverContactController = TextEditingController();
  final _fareOverrideController = TextEditingController();

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  DateTime? _selectedDateTime;
  String _busClass = 'Ordinary';
  bool _isLoading = false;
  bool _isLoadingRoutes = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.existingTrip != null) {
      final t = widget.existingTrip!;
      _seatCountController.text = t.vehicleSeatCount.toString();
      _maxCargoController.text = t.maxCargoKg.toString();
      _plateController.text = t.busNumberPlate ?? '';
      _colorController.text = t.busColor ?? '';
      _driverNameController.text = t.driverName ?? '';
      _driverContactController.text = t.driverContact ?? '';
      _fareOverrideController.text = t.fareOverride?.toString() ?? '';
      _busClass = t.busClass;
      _selectedDateTime = t.departureTime;
    }
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes = await _tripService.getAllRoutes();
      setState(() {
        _routes = routes;
        _isLoadingRoutes = false;
        if (widget.existingTrip != null) {
          _selectedRoute = routes.where((r) => r.id == widget.existingTrip!.routeId).firstOrNull;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingRoutes = false;
        _errorMessage = 'Could not load routes: $e';
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
          busNumberPlate: _plateController.text.trim().isEmpty ? null : _plateController.text.trim(),
          busColor: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
          busClass: _busClass,
          driverName: _driverNameController.text.trim().isEmpty ? null : _driverNameController.text.trim(),
          driverContact: _driverContactController.text.trim().isEmpty ? null : _driverContactController.text.trim(),
          fareOverride: _fareOverrideController.text.trim().isEmpty
              ? null
              : double.parse(_fareOverrideController.text.trim()),
        );
      } else {
        await _tripService.createTrip(
          routeId: _selectedRoute!.id,
          departureTime: _selectedDateTime!,
          seatCount: int.parse(_seatCountController.text.trim()),
          maxCargoKg: double.parse(_maxCargoController.text.trim()),
          busNumberPlate: _plateController.text.trim().isEmpty ? null : _plateController.text.trim(),
          busColor: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
          busClass: _busClass,
          driverName: _driverNameController.text.trim().isEmpty ? null : _driverNameController.text.trim(),
          driverContact: _driverContactController.text.trim().isEmpty ? null : _driverContactController.text.trim(),
          fareOverride: _fareOverrideController.text.trim().isEmpty
              ? null
              : double.parse(_fareOverrideController.text.trim()),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _classTab(String value) {
    final isSelected = _busClass == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _busClass = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kAuthAccentBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: _isLoadingRoutes
            ? const Center(child: CircularProgressIndicator(color: kAuthAccentMint))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('Schedule a Trip',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthFieldLabel('ROUTE'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.18)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RouteModel>(
                          isExpanded: true,
                          dropdownColor: const Color(0xFF17242A),
                          value: _selectedRoute,
                          hint: Text('Select a route', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                          style: const TextStyle(color: Colors.white),
                          items: _routes.map((route) {
                            return DropdownMenuItem(
                              value: route,
                              child: Text('${route.origin} → ${route.destination}'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedRoute = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const AuthFieldLabel('NUMBER OF SEATS'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _seatCountController, hint: '14', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('MAX CARGO CAPACITY (KG)'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _maxCargoController, hint: '100', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('BUS NUMBER PLATE'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _plateController, hint: 'e.g. UBH 123X'),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('BUS COLOR'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _colorController, hint: 'e.g. White with blue stripe'),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('BUS CLASS'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _classTab('Ordinary'),
                        const SizedBox(width: 8),
                        _classTab('Executive'),
                        const SizedBox(width: 8),
                        _classTab('VIP'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('DRIVER NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _driverNameController, hint: 'e.g. Moses Okello'),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('DRIVER CONTACT'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _driverContactController, hint: '+256...', keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),

                    const AuthFieldLabel('FARE OVERRIDE (OPTIONAL)'),
                    const SizedBox(height: 8),
                    GlassTextField(
                      controller: _fareOverrideController,
                      hint: 'Leave blank to use the route\'s base fare',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.18)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: kAuthAccentMint, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              _selectedDateTime == null
                                  ? 'Pick departure date & time'
                                  : _selectedDateTime.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    if (_errorMessage != null) AuthErrorText(_errorMessage!),
                    GlassGradientButton(label: 'Create Trip', isLoading: _isLoading, onTap: _handleCreate),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
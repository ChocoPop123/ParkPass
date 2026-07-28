import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/route_model.dart';
import '../../models/trip_model.dart';
import '../../services/trip_service.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class CreateTripScreen extends StatefulWidget {
  final TripModel? existingTrip;
  const CreateTripScreen({super.key, this.existingTrip});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _tripService = TripService();
  final _companyService = CompanyService();
  
  late final TextEditingController _seatCountController;
  late final TextEditingController _maxCargoController;
  late final TextEditingController _plateController;
  late final TextEditingController _colorController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _driverContactController;
  late final TextEditingController _fareOverrideController;

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  DateTime? _selectedDateTime;
  String _selectedBusClass = 'Ordinary';
  
  bool _isLoading = false;
  bool _isLoadingRoutes = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final trip = widget.existingTrip;
    _seatCountController = TextEditingController(text: trip?.vehicleSeatCount.toString() ?? '14');
    _maxCargoController = TextEditingController(text: trip?.maxCargoKg.toString() ?? '100');
    _plateController = TextEditingController(text: trip?.busNumberPlate ?? '');
    _colorController = TextEditingController(text: trip?.busColor ?? '');
    _driverNameController = TextEditingController(text: trip?.driverName ?? '');
    _driverContactController = TextEditingController(text: trip?.driverContact ?? '');
    _fareOverrideController = TextEditingController(text: trip?.fareOverride?.toString() ?? '');
    
    _selectedDateTime = trip?.departureTime;
    _selectedBusClass = trip?.busClass ?? 'Ordinary';

    _loadRoutes();
  }

  @override
  void dispose() {
    _seatCountController.dispose();
    _maxCargoController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _driverNameController.dispose();
    _driverContactController.dispose();
    _fareOverrideController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    try {
      final companyId = await _companyService.getMyCompanyId();
      final routes = await _tripService.getAllRoutes(companyId: companyId);
      
      setState(() {
        _routes = routes;
        _isLoadingRoutes = false;

        if (widget.existingTrip != null) {
          try {
            _selectedRoute = routes.firstWhere((r) => r.id == widget.existingTrip!.routeId);
          } catch (_) {}
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingRoutes = false;
        _errorMessage = 'Failed to load routes: $e';
      });
    }
  }

  Future<void> _pickDateTime() async {
    final initialDate = _selectedDateTime ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(DateTime.now()) ? DateTime.now() : initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light(),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light(),
        child: child!,
      ),
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
      final fareOverride = double.tryParse(_fareOverrideController.text.trim());
      
      if (widget.existingTrip != null) {
        await _tripService.updateTrip(
          tripId: widget.existingTrip!.id,
          routeId: _selectedRoute!.id,
          departureTime: _selectedDateTime!,
          seatCount: int.parse(_seatCountController.text.trim()),
          maxCargoKg: double.parse(_maxCargoController.text.trim()),
          busNumberPlate: _plateController.text.trim(),
          busColor: _colorController.text.trim(),
          busClass: _selectedBusClass,
          driverName: _driverNameController.text.trim(),
          driverContact: _driverContactController.text.trim(),
          fareOverride: fareOverride,
        );
      } else {
        await _tripService.createTrip(
          routeId: _selectedRoute!.id,
          departureTime: _selectedDateTime!,
          seatCount: int.parse(_seatCountController.text.trim()),
          maxCargoKg: double.parse(_maxCargoController.text.trim()),
          busNumberPlate: _plateController.text.trim(),
          busColor: _colorController.text.trim(),
          busClass: _selectedBusClass,
          driverName: _driverNameController.text.trim(),
          driverContact: _driverContactController.text.trim(),
          fareOverride: fareOverride,
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
    final colors = AppColors.of(context);
    final isEditing = widget.existingTrip != null;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuthBackground(
        child: _isLoadingRoutes
            ? Center(child: CircularProgressIndicator(color: colors.accent))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isEditing ? "Update Trip" : "Schedule Trip",
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isEditing ? "Update journey details" : "Create a new journey for passengers",
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthFieldLabel('ROUTE'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.neutralBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<RouteModel>(
                          isExpanded: true,
                          dropdownColor: colors.surface,
                          value: _selectedRoute,
                          hint: Text(
                            'Select a route',
                            style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
                          ),
                          style: TextStyle(color: colors.textPrimary),
                          items: _routes.map((route) {
                            return DropdownMenuItem(
                              value: route,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${route.origin} → ${route.destination}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "UGX ${route.baseFare.toStringAsFixed(0)}",
                                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
                    const AuthFieldLabel('DEPARTURE TIME'),
                    const SizedBox(height: 8),
                    GlassSelectorChip(
                      icon: Icons.calendar_today,
                      label: _selectedDateTime == null
                          ? 'Pick date & time'
                          : DateFormat('dd MMM yyyy, hh:mm a').format(_selectedDateTime!),
                      onTap: _pickDateTime,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text('BUS DETAILS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthFieldLabel('BUS CLASS'),
                    const SizedBox(height: 8),
                    Row(
                      children: ['Ordinary', 'Executive', 'VIP'].map((c) {
                        final sel = _selectedBusClass == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: sel,
                            onSelected: (v) => setState(() => _selectedBusClass = c),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthFieldLabel('PLATE NUMBER'),
                              const SizedBox(height: 8),
                              GlassTextField(controller: _plateController, hint: 'UAB 123X'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthFieldLabel('BUS COLOR'),
                              const SizedBox(height: 8),
                              GlassTextField(controller: _colorController, hint: 'White'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthFieldLabel('SEATS'),
                              const SizedBox(height: 8),
                              GlassTextField(controller: _seatCountController, hint: '14', keyboardType: TextInputType.number),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AuthFieldLabel('CARGO (KG)'),
                              const SizedBox(height: 8),
                              GlassTextField(controller: _maxCargoController, hint: '100', keyboardType: TextInputType.number),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              const Text('DRIVER & FARE', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthFieldLabel('DRIVER NAME'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _driverNameController, hint: 'John Doe'),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('FARE OVERRIDE (OPTIONAL)'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _fareOverrideController, hint: 'Leave empty for base fare', keyboardType: TextInputType.number),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              if (_errorMessage != null) AuthErrorText(_errorMessage!),
              GlassGradientButton(
                label: isEditing ? 'Update Trip' : 'Create Trip',
                isLoading: _isLoading,
                onTap: _handleCreate,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

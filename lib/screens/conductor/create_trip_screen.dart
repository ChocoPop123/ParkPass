import 'package:flutter/material.dart';
import '../../models/route_model.dart';
import '../../services/trip_service.dart';

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final _tripService = TripService();
  final _seatCountController = TextEditingController(text: '14');
  final _maxCargoController = TextEditingController(text: '100');

  List<RouteModel> _routes = [];
  RouteModel? _selectedRoute;
  DateTime? _selectedDateTime;
  bool _isLoading = false;
  bool _isLoadingRoutes = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final routes = await _tripService.getAllRoutes();
    setState(() {
      _routes = routes;
      _isLoadingRoutes = false;
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      await _tripService.createTrip(
        routeId: _selectedRoute!.id,
        departureTime: _selectedDateTime!,
        seatCount: int.parse(_seatCountController.text.trim()),
        maxCargoKg: double.parse(_maxCargoController.text.trim()),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule a Trip')),
      body: _isLoadingRoutes
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Route'),
            DropdownButton<RouteModel>(
              isExpanded: true,
              value: _selectedRoute,
              hint: const Text('Select a route'),
              items: _routes.map((route) {
                return DropdownMenuItem(
                  value: route,
                  child: Text('${route.origin} → ${route.destination}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedRoute = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _seatCountController,
              decoration: const InputDecoration(labelText: 'Number of seats'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _maxCargoController,
              decoration: const InputDecoration(labelText: 'Max cargo capacity (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                _selectedDateTime == null
                    ? 'Pick departure date & time'
                    : _selectedDateTime.toString(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _handleCreate,
              child: const Text('Create Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
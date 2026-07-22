import 'package:flutter/material.dart';
import '../../services/trip_service.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}


class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _tripService = TripService();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _fareController = TextEditingController();
  final _cargoPriceController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _fareController.dispose();
    _cargoPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_originController.text.isEmpty || 
        _destinationController.text.isEmpty || 
        _fareController.text.isEmpty || 
        _cargoPriceController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _tripService.createRoute(
        origin: _originController.text.trim(),
        destination: _destinationController.text.trim(),
        baseFare: double.parse(_fareController.text.trim()),
        cargoPricePerKg: double.parse(_cargoPriceController.text.trim()),
      );
      if (mounted) Navigator.pop(context, true); // true = "something was created"
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Route')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _originController,
              decoration: const InputDecoration(labelText: 'Origin (e.g. Kampala)'),
            ),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(labelText: 'Destination (e.g. Gulu)'),
            ),
            TextField(
              controller: _fareController,
              decoration: const InputDecoration(labelText: 'Base fare per seat (UGX)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _cargoPriceController,
              decoration: const InputDecoration(labelText: 'Cargo price per kg (UGX)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleCreate,
                      child: const Text('Create Route'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/trip_service.dart';
import '../../services/company_service.dart';
import '../../widgets/glass_widgets.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _tripService = TripService();
  final _companyService = CompanyService();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _fareController = TextEditingController();
  final _cargoPriceController = TextEditingController();

  String? _companyId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    try {
      final id = await _companyService.getMyCompanyId();
      setState(() => _companyId = id);
    } catch (e) {
      setState(() => _errorMessage = 'Could not load your company: $e');
    }
  }

  Future<void> _handleCreate() async {
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
        companyId: _companyId!,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
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
                  const Text('Create Route',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthFieldLabel('ORIGIN'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _originController, hint: 'e.g. Kampala'),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('DESTINATION'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _destinationController, hint: 'e.g. Gulu'),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('BASE FARE PER SEAT (UGX)'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _fareController, hint: 'e.g. 45000', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    const AuthFieldLabel('CARGO PRICE PER KG (UGX)'),
                    const SizedBox(height: 8),
                    GlassTextField(controller: _cargoPriceController, hint: 'e.g. 2000', keyboardType: TextInputType.number),
                    const SizedBox(height: 22),
                    if (_errorMessage != null) AuthErrorText(_errorMessage!),
                    GlassGradientButton(label: 'Create Route', isLoading: _isLoading, onTap: _handleCreate),
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
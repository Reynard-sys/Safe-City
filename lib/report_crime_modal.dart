import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'report_crime_summary.dart';

class ReportCrimeModal extends StatefulWidget {
  const ReportCrimeModal({super.key});

  @override
  State<ReportCrimeModal> createState() => _ReportCrimeModalState();
}

class _ReportCrimeModalState extends State<ReportCrimeModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCrimeType;
  final _locationService = Location();

  final List<String> _crimeTypes = ['Theft', 'Assault', 'Harassment', 'Vandalism', 'Other'];

  double _initialSheetSize = 0.8;

  @override
  void initState() {
    super.initState();
    _fillCurrentLocation();
  }

  Future<void> _fillCurrentLocation() async {
    final hasPermission = await _locationService.hasPermission();
    if (hasPermission == PermissionStatus.denied) {
      final granted = await _locationService.requestPermission();
      if (granted != PermissionStatus.granted) return;
    }

    final locationData = await _locationService.getLocation();

    try {
      final placemarks = await geo.placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      setState(() {
        _locationController.text = "${locationData.latitude}, ${locationData.longitude}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Color(0xFF0404BC)),
                const SizedBox(height: 16),
                const Text('Confirm Submission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to submit this crime report?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF0404BC)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF0404BC))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0404BC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ?? false;

      if (confirmed) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (_) => CrimeReportSummaryModal(
            name: _nameController.text,
            contact: _contactController.text,
            location: _locationController.text,
            type: _selectedCrimeType ?? 'Unknown',
            description: _descriptionController.text,
          ),
        );
      }
    } else {
      setState(() {
        _initialSheetSize = 0.9;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetSize,
      minChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: SingleChildScrollView(
          controller: controller,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, size: 28, color: Colors.black87),
                    ),
                    const SizedBox(width: 16),
                    const Text("Report a Crime", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(controller: _nameController, label: 'Your Name', validator: _required),
                _buildTextField(controller: _contactController, label: 'Contact Info (optional)'),
                _buildDropdown(),
                _buildLocationField(),
                _buildTextField(controller: _descriptionController, label: 'Description', maxLines: 4, validator: _required),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitForm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0404BC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0404BC).withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Submit Report",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFFF9F9FB),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Crime Type',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFFF9F9FB),
        ),
        value: _selectedCrimeType,
        items: _crimeTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        onChanged: (value) => setState(() => _selectedCrimeType = value),
        validator: (value) => value == null ? 'Select a crime type' : null,
      ),
    );
  }

  Widget _buildLocationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _locationController,
        validator: _required,
        decoration: InputDecoration(
          labelText: 'Location',
          suffixIcon: const Icon(Icons.location_on),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: const Color(0xFFF9F9FB),
        ),
      ),
    );
  }

  String? _required(String? value) => (value == null || value.isEmpty) ? 'Required field' : null;
}

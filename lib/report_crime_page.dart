import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'report_crime_summary.dart';

class ReportCrimePage extends StatefulWidget {
  const ReportCrimePage({super.key});

  @override
  State<ReportCrimePage> createState() => _ReportCrimePageState();
}

class _ReportCrimePageState extends State<ReportCrimePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCrimeType;
  final _locationService = Location();

  final List<String> _crimeTypes = ['Theft', 'Assault', 'Harassment', 'Vandalism', 'Other'];

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
      final confirmed = await _showConfirmationDialog();
      if (confirmed) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CrimeReportSummaryPage(
              name: _nameController.text,
              contact: _contactController.text,
              location: _locationController.text,
              type: _selectedCrimeType ?? 'Unknown',
              description: _descriptionController.text,
            ),
          ),
        );

        _formKey.currentState!.reset();
        _nameController.clear();
        _contactController.clear();
        _locationController.clear();
        _descriptionController.clear();
        setState(() => _selectedCrimeType = null);
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this report?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Submit')),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            color: const Color(0xFFE5FFFF),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/combined_logo.png', width: 10, height: 10),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.contact_support_rounded), onPressed: () => Navigator.pushNamed(context, '/chat')),
                    IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 120, bottom: 100, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("Report a Crime", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildTextField(controller: _nameController, label: 'Your Name', validator: _required),
                      _buildTextField(controller: _contactController, label: 'Contact Info (optional)'),
                      _buildDropdown(),
                      _buildLocationField(),
                      _buildTextField(controller: _descriptionController, label: 'Description', maxLines: 4, validator: _required),
                      const SizedBox(height: 20),
                      _buildGradientButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey, width: 2))),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NavItem(icon: Icons.location_on, label: 'Maps', onTap: () => Navigator.pop(context)),
                NavItem(icon: Icons.local_police_sharp, label: 'Report a Crime', onTap: () {}),
                NavItem(icon: Icons.phone_in_talk, label: 'Fake Call', onTap: () => Navigator.pushNamed(context, '/fake')),
                NavItem(icon: Icons.nordic_walking, label: 'Walk-with-Me', onTap: () {}),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildGradientButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _submitForm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF8E76FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 10)],
          ),
          child: const Center(
            child: Text("Submit Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
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

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CrimeReportSummaryPage extends StatelessWidget {
  final String? name;
  final String? contact;
  final String? location;
  final String? type;
  final String? description;

  const CrimeReportSummaryPage({
    super.key,
    this.name,
    this.contact,
    this.location,
    this.type,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Crime Report Summary",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        _buildDetailRow("Name", name),
                        _buildDetailRow("Contact", contact),
                        _buildDetailRow("Location", location),
                        _buildDetailRow("Type", type),
                        _buildDetailRow("Description", description),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Done"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFE0F7FA),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/combined_logo.png', width: 40, height: 40),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.contact_support_rounded, color: Colors.black87),
                onPressed: () => Navigator.pushNamed(context, '/chat'),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black87),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : "N/A",
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.location_on, 'Maps', () => Navigator.pushNamed(context, '/map')),
          _buildNavItem(Icons.local_police_sharp, 'Report', () => Navigator.pushNamed(context, '/report_crime')),
          _buildNavItem(Icons.phone_in_talk, 'Fake Call', () => Navigator.pushNamed(context, '/fake_call')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}

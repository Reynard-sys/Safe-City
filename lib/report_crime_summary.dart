import 'package:flutter/material.dart';

class CrimeReportSummaryModal extends StatelessWidget {
  final String? name;
  final String? contact;
  final String? location;
  final String? type;
  final String? description;

  const CrimeReportSummaryModal({
    super.key,
    this.name,
    this.contact,
    this.location,
    this.type,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Title Only (No X)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "Crime Report Summary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // Summary Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildIconRow(Icons.person, "Name", name),
                  _buildIconRow(Icons.phone, "Contact", contact),
                  _buildIconRow(Icons.location_on, "Location", location),
                  _buildIconRow(Icons.warning_amber_rounded, "Type", type),
                  _buildIconRow(Icons.description, "Description", description),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Done Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Close summary modal
                Navigator.of(context).pop(); // Close report modal
              },
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text("Export & Done"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F9D58),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                  TextSpan(
                    text: value?.isNotEmpty == true ? value! : "N/A",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

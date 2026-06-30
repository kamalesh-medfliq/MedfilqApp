import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/patient.dart';

class PatientProfileScreen extends StatelessWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBackground : const Color(0xFFF1F5F9);
    final cardColor = isDark ? const Color(0xFF262220) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1A18);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text("Patient Profile", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: DefaultTabController(
        length: 8,
        child: Column(
          children: [
            _buildPatientHeader(context, cardColor, textColor, isDark),
            TabBar(
              isScrollable: true,
              labelColor: AppTheme.primaryOrange,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryOrange,
              tabs: const [
                Tab(text: "Profile"),
                Tab(text: "Timeline"),
                Tab(text: "Appointment History"),
                Tab(text: "SOAP Notes"),
                Tab(text: "Prescriptions"),
                Tab(text: "Lab Results"),
                Tab(text: "Documents"),
                Tab(text: "Audit History"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildProfileTab(cardColor, textColor, isDark),
                  _buildPlaceholderTab("Timeline", isDark),
                  _buildPlaceholderTab("Appointment History", isDark),
                  _buildPlaceholderTab("SOAP Notes", isDark),
                  _buildPlaceholderTab("Prescriptions", isDark),
                  _buildPlaceholderTab("Lab Results", isDark),
                  _buildPlaceholderTab("Documents", isDark),
                  _buildPlaceholderTab("Audit History", isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(BuildContext context, Color cardColor, Color textColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                child: Text(
                  patient.firstName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(patient.fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: patient.status == 'ACTIVE' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            patient.status,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: patient.status == 'ACTIVE' ? Colors.green : Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(patient.patientNumber, style: const TextStyle(fontSize: 14, color: AppTheme.primaryOrange, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _infoChip(Icons.cake, '${patient.age} years'),
                        _infoChip(Icons.person, patient.gender),
                        _infoChip(Icons.water_drop, patient.bloodGroup ?? 'Unknown'),
                        _infoChip(Icons.phone, patient.phone),
                        _infoChip(Icons.calendar_today, 'Last Visit: N/A'),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildProfileTab(Color cardColor, Color textColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Personal Information", textColor),
          _buildInfoCard(cardColor, isDark, [
            _buildDetailRow("First Name", patient.firstName, textColor),
            _buildDetailRow("Last Name", patient.lastName, textColor),
            _buildDetailRow("Date of Birth", "${patient.dateOfBirth.day}/${patient.dateOfBirth.month}/${patient.dateOfBirth.year}", textColor),
            _buildDetailRow("Email", patient.email ?? 'N/A', textColor),
            _buildDetailRow("Address", [patient.address, patient.city, patient.state, patient.pincode].where((e) => e != null && e.isNotEmpty).join(', '), textColor),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle("Emergency Contact", textColor),
          _buildInfoCard(cardColor, isDark, [
            _buildDetailRow("Name", patient.emergencyContactName ?? 'N/A', textColor),
            _buildDetailRow("Phone", patient.emergencyContactPhone ?? 'N/A', textColor),
            _buildDetailRow("Relationship", patient.relationship ?? 'N/A', textColor),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle("Medical Information", textColor),
          _buildInfoCard(cardColor, isDark, [
            _buildDetailRow("Allergies", (patient.allergies ?? []).isEmpty ? 'None' : patient.allergies!.join(', '), textColor),
            _buildDetailRow("Chronic Diseases", (patient.chronicDiseases ?? []).isEmpty ? 'None' : patient.chronicDiseases!.join(', '), textColor),
            _buildDetailRow("Medical Notes", patient.medicalNotes ?? 'None', textColor),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
    );
  }

  Widget _buildInfoCard(Color cardColor, bool isDark, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'N/A' : value, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("$title module is coming in a future sprint.", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }
}

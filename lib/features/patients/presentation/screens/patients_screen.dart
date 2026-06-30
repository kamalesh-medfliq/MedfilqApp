import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/patient_provider.dart';
import 'patient_profile_screen.dart';
import '../widgets/patient_form_modal.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients(refresh: true);
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<PatientProvider>().fetchPatients();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<PatientProvider>().fetchPatients(refresh: true, search: query);
  }

  void _showAddPatientModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1A18) : Colors.white;
    final fgColor = isDark ? Colors.white : const Color(0xFF1E1A18);
    final cardColor = isDark ? const Color(0xFF262220) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PatientFormModal(
        bgColor: bgColor,
        fgColor: fgColor,
        cardColor: cardColor,
        borderColor: borderColor,
        onSuccess: () {
          context.read<PatientProvider>().fetchPatients(refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<PatientProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Patients", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1E1A18))),
                ElevatedButton.icon(
                  onPressed: () => _showAddPatientModal(context),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("New Patient", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: "Search patients by name, phone, or PAT-number...",
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                filled: true,
                fillColor: isDark ? const Color(0xFF262220) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildBody(provider, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PatientProvider provider, bool isDark) {
    if (provider.isLoading && provider.patients.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
    }
    
    if (provider.error != null && provider.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(provider.error!, style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchPatients(refresh: true),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
    
    if (provider.patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty ? "No patients found in this clinic." : "No matching patients found.",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => provider.fetchPatients(refresh: true, search: _searchController.text),
      color: AppTheme.primaryOrange,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: provider.patients.length + (provider.isFetchingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == provider.patients.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
            );
          }
          
          final patient = provider.patients[index];
          final bgColor = isDark ? const Color(0xFF262220) : Colors.white;
          final textColor = isDark ? Colors.white : const Color(0xFF1E1A18);
          
          return InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => PatientProfileScreen(patient: patient)));
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.1),
                    child: Text(patient.firstName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 4),
                        Text(patient.patientNumber, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: patient.status == 'ACTIVE' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          patient.status,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: patient.status == 'ACTIVE' ? Colors.green : Colors.orange),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${patient.age} yrs • ${patient.gender}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/patient_provider.dart';

class PatientFormModal extends StatefulWidget {
  final Color bgColor;
  final Color fgColor;
  final Color cardColor;
  final Color borderColor;
  final VoidCallback? onSuccess;

  const PatientFormModal({
    super.key,
    required this.bgColor,
    required this.fgColor,
    required this.cardColor,
    required this.borderColor,
    this.onSuccess,
  });

  @override
  State<PatientFormModal> createState() => _PatientFormModalState();
}

class _PatientFormModalState extends State<PatientFormModal> {
  bool _isSubmitting = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController(text: 'Male');
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  DateTime? _selectedDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit({bool force = false}) async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty || _phoneController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'gender': _genderController.text,
      'dateOfBirth': _selectedDate!.toIso8601String(),
      'phone': _phoneController.text.trim(),
    };

    final result = await context.read<PatientProvider>().createPatient(payload, force: force);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context);
      if (widget.onSuccess != null) widget.onSuccess!();
    } else if (result['isDuplicate'] == true) {
      setState(() => _isSubmitting = false);
      final duplicates = result['duplicates'] as List;
      final dup = duplicates.first;
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: widget.bgColor,
          title: Text("Possible duplicate patient found", style: TextStyle(color: widget.fgColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("A similar patient already exists:", style: TextStyle(color: widget.fgColor)),
              const SizedBox(height: 12),
              Text("Patient No: ${dup['patientNumber']}", style: TextStyle(color: widget.fgColor, fontWeight: FontWeight.bold)),
              Text("Name: ${dup['name']}", style: TextStyle(color: widget.fgColor)),
              Text("Phone: ${dup['phone']}", style: TextStyle(color: widget.fgColor)),
              const SizedBox(height: 16),
              Text("Do you want to continue creating this patient?", style: TextStyle(color: widget.fgColor)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _submit(force: true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
              child: const Text("Create Anyway", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['error']),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: widget.bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Add Patient", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.fgColor)),
                  IconButton(
                    icon: Icon(Icons.close, color: widget.fgColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField("First Name*", _firstNameController),
              const SizedBox(height: 16),
              _buildTextField("Last Name*", _lastNameController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                            _dobController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                      child: IgnorePointer(
                        child: _buildTextField("Date of Birth*", _dobController),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _genderController.text,
                      dropdownColor: widget.cardColor,
                      style: TextStyle(color: widget.fgColor),
                      decoration: InputDecoration(
                        labelText: "Gender*",
                        labelStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: widget.cardColor,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
                      ),
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setState(() => _genderController.text = newValue);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("Phone*", _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Create Patient", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: widget.fgColor),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: widget.cardColor,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: widget.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryOrange)),
      ),
    );
  }
}

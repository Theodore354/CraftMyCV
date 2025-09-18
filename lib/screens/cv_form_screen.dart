// lib/screens/cv_form_screen.dart
import 'package:flutter/material.dart';
import 'results_screen.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobStartDateController = TextEditingController();
  final _jobEndDateController = TextEditingController();
  final _responsibilitiesController = TextEditingController();

  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  final _eduStartDateController = TextEditingController();
  final _eduEndDateController = TextEditingController();

  final _skillsController = TextEditingController();

  // Pick date helper
  Future<void> _pickDate(TextEditingController controller, String label) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void _generateCV() {
    if (!_formKey.currentState!.validate()) return;

    final dummyCV = """
Name: ${_nameController.text}
Email: ${_emailController.text}
Phone: ${_phoneController.text}
Location: ${_locationController.text}

Work Experience
Job Title: ${_jobTitleController.text}
Company: ${_companyController.text}
Start: ${_jobStartDateController.text} - End: ${_jobEndDateController.text}
Responsibilities: ${_responsibilitiesController.text}

Education
Degree: ${_degreeController.text}
Institution: ${_institutionController.text}
Start: ${_eduStartDateController.text} - End: ${_eduEndDateController.text}

Skills: ${_skillsController.text}

(This is a sample CV, later we’ll replace this with AI-generated content.)
""";

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(resultText: dummyCV)),
      );
    }
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create CV"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Personal Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildField(
                label: "Full Name",
                controller: _nameController,
                validator:
                    (val) =>
                        val == null || val.isEmpty ? "Name is required" : null,
              ),
              _buildField(
                label: "Email",
                controller: _emailController,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email is required";
                  if (!RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(val)) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              _buildField(
                label: "Phone Number",
                controller: _phoneController,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return "Phone number is required";
                  }
                  if (!RegExp(r'^\d{7,15}$').hasMatch(val)) {
                    return "Enter a valid phone number";
                  }
                  return null;
                },
              ),
              _buildField(
                label: "Location",
                controller: _locationController,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Location is required"
                            : null,
              ),

              const SizedBox(height: 16),
              const Text(
                "Work Experience",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildField(
                label: "Job Title",
                controller: _jobTitleController,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Job title is required"
                            : null,
              ),
              _buildField(
                label: "Company",
                controller: _companyController,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Company is required"
                            : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: "Start Date",
                      controller: _jobStartDateController,
                      readOnly: true,
                      onTap:
                          () =>
                              _pickDate(_jobStartDateController, "Start Date"),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "Start date required"
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      label: "End Date",
                      controller: _jobEndDateController,
                      readOnly: true,
                      onTap: () => _pickDate(_jobEndDateController, "End Date"),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "End date required"
                                  : null,
                    ),
                  ),
                ],
              ),
              _buildField(
                label: "Responsibilities",
                controller: _responsibilitiesController,
                maxLines: 3,
              ),

              const SizedBox(height: 16),
              const Text(
                "Education",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildField(
                label: "Degree",
                controller: _degreeController,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Degree is required"
                            : null,
              ),
              _buildField(
                label: "Institution",
                controller: _institutionController,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "Institution is required"
                            : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: "Start Date",
                      controller: _eduStartDateController,
                      readOnly: true,
                      onTap:
                          () =>
                              _pickDate(_eduStartDateController, "Start Date"),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "Start date required"
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      label: "End Date",
                      controller: _eduEndDateController,
                      readOnly: true,
                      onTap: () => _pickDate(_eduEndDateController, "End Date"),
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? "End date required"
                                  : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                "Skills",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildField(
                label: "Add Skills",
                controller: _skillsController,
                validator:
                    (val) =>
                        val == null || val.isEmpty
                            ? "At least 1 skill required"
                            : null,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _generateCV,
                  child: const Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

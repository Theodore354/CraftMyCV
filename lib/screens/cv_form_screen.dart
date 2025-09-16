import 'package:flutter/material.dart';
import 'results_screen.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _jobStartDateController.dispose();
    _jobEndDateController.dispose();
    _responsibilitiesController.dispose();
    _degreeController.dispose();
    _institutionController.dispose();
    _eduStartDateController.dispose();
    _eduEndDateController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 5),
      initialDate: now,
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _generateCV() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in required fields")),
      );
      return;
    }

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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(resultText: dummyCV)),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, TextEditingController controller) {
    return InkWell(
      onTap: () => _pickDate(controller),
      child: IgnorePointer(
        child: _buildField(label: label, controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create CV"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
              textInputAction: TextInputAction.next,
            ),
            _buildField(
              label: "Email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            _buildField(
              label: "Phone Number",
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            _buildField(
              label: "Location",
              controller: _locationController,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),
            const Text(
              "Work Experience",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildField(
              label: "Job Title",
              controller: _jobTitleController,
              textInputAction: TextInputAction.next,
            ),
            _buildField(
              label: "Company",
              controller: _companyController,
              textInputAction: TextInputAction.next,
            ),
            Row(
              children: [
                Expanded(
                  child: _dateField("Start Date", _jobStartDateController),
                ),
                const SizedBox(width: 10),
                Expanded(child: _dateField("End Date", _jobEndDateController)),
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
            _buildField(label: "Degree", controller: _degreeController),
            _buildField(
              label: "Institution",
              controller: _institutionController,
            ),
            Row(
              children: [
                Expanded(
                  child: _dateField("Start Date", _eduStartDateController),
                ),
                const SizedBox(width: 10),
                Expanded(child: _dateField("End Date", _eduEndDateController)),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "Skills",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildField(label: "Add Skills", controller: _skillsController),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _generateCV,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text("Next", style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'results_screen.dart';

class CvFormScreen extends StatefulWidget {
  const CvFormScreen({super.key});

  @override
  State<CvFormScreen> createState() => _CvFormScreenState();
}

class _CvFormScreenState extends State<CvFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers — Personal
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  // Controllers — Work
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobStartDateController = TextEditingController();
  final _jobEndDateController = TextEditingController();
  final _responsibilitiesController = TextEditingController();

  // Controllers — Education
  final _degreeController = TextEditingController();
  final _institutionController = TextEditingController();
  final _eduStartDateController = TextEditingController();
  final _eduEndDateController = TextEditingController();

  // Controllers — Skills
  final _skillsController = TextEditingController();

  // Toggles for "Present"
  bool _isCurrentJob = false;
  bool _isCurrentEdu = false;

  // ===== Helpers (trim & normalize) ==========================================
  String _t(TextEditingController c) => c.text.trim();

  String _normalizeSpaces(String s) {
    // Collapse extra spaces/newlines.
    final t = s
        .replaceAll(RegExp(r'[ \t]+\n'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return t.trim();
  }

  String _normalizeCommaList(String s) {
    // Split by comma/semicolon/newline and re-join with a clean ", "
    final parts =
        s
            .split(RegExp(r'[,\n;]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    return parts.join(', ');
  }

  // Month names for MMM formatting (no extra deps)
  static const List<String> _mmm = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String _formatMonthYear(DateTime d) => '${_mmm[d.month - 1]} ${d.year}';

  // Pick date helper -> stores as "MMM yyyy"
  Future<void> _pickDate(TextEditingController controller, String label) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
      helpText: label, // header label
    );
    if (picked != null) {
      controller.text = _formatMonthYear(picked);
    }
  }

  void _generateCV() {
    // Close keyboard first for better UX
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    // normalized values
    final name = _t(_nameController);
    final email = _t(_emailController).toLowerCase();
    final phone = _t(_phoneController);
    final location = _t(_locationController);

    final jobTitle = _t(_jobTitleController);
    final company = _t(_companyController);
    final jobStart = _t(_jobStartDateController);
    final jobEnd = _isCurrentJob ? "Present" : _t(_jobEndDateController);
    final responsibilities = _normalizeSpaces(_t(_responsibilitiesController));

    final degree = _t(_degreeController);
    final institution = _t(_institutionController);
    final eduStart = _t(_eduStartDateController);
    final eduEnd = _isCurrentEdu ? "Present" : _t(_eduEndDateController);

    final skills = _normalizeCommaList(_t(_skillsController));

    final dummyCV = """
Name: $name
Email: $email
Phone: $phone
Location: $location

Work Experience
Job Title: $jobTitle
Company: $company
Start: $jobStart - End: $jobEnd
Responsibilities: $responsibilities

Education
Degree: $degree
Institution: $institution
Start: $eduStart - End: $eduEnd

Skills: $skills

(This is a sample CV, later we’ll replace this with AI-generated content.)
""";

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultsScreen(resultText: dummyCV)),
      );
    }
  }

  // Reusable field builder with better keyboard/autofill ergonomics
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create CV"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction, // live feedback
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
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Name is required"
                            : null,
              ),
              _buildField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (val) {
                  final v = val?.trim() ?? "";
                  if (v.isEmpty) return "Email is required";
                  final ok = RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(v);
                  return ok ? null : "Enter a valid email";
                },
              ),
              _buildField(
                label: "Phone Number",
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  final v = val?.trim() ?? "";
                  if (v.isEmpty) return "Phone number is required";
                  final ok = RegExp(r'^\d{7,15}$').hasMatch(v);
                  return ok ? null : "Enter a valid phone number (digits only)";
                },
              ),
              _buildField(
                label: "Location",
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.addressCityAndState],
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
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
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Job title is required"
                            : null,
              ),
              _buildField(
                label: "Company",
                controller: _companyController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Company is required"
                            : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: "Start (MMM yyyy)",
                      hintText: "e.g., Jan 2024",
                      controller: _jobStartDateController,
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      onTap:
                          () => _pickDate(
                            _jobStartDateController,
                            "Start (Month & Year)",
                          ),
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? "Start date required"
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      label: "End (MMM yyyy / Present)",
                      hintText: "e.g., Jun 2025",
                      controller: _jobEndDateController,
                      readOnly: true,
                      enabled: !_isCurrentJob, // show disabled style
                      onTap:
                          _isCurrentJob
                              ? null
                              : () => _pickDate(
                                _jobEndDateController,
                                "End (Month & Year)",
                              ),
                      validator: (val) {
                        if (_isCurrentJob) return null; // Present is implied
                        return (val == null || val.trim().isEmpty)
                            ? "End date required"
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              // Toggle: I currently work here
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("I currently work here"),
                value: _isCurrentJob,
                onChanged: (v) {
                  setState(() {
                    _isCurrentJob = v ?? false;
                    if (_isCurrentJob) {
                      _jobEndDateController.text = "Present";
                    } else {
                      _jobEndDateController.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              _buildField(
                label: "Responsibilities",
                controller: _responsibilitiesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 16),
              const Text(
                "Education",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildField(
                label: "Degree",
                controller: _degreeController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Degree is required"
                            : null,
              ),
              _buildField(
                label: "Institution",
                controller: _institutionController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
                            ? "Institution is required"
                            : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      label: "Start (MMM yyyy)",
                      hintText: "e.g., Sep 2020",
                      controller: _eduStartDateController,
                      readOnly: true,
                      textInputAction: TextInputAction.next,
                      onTap:
                          () => _pickDate(
                            _eduStartDateController,
                            "Start (Month & Year)",
                          ),
                      validator:
                          (val) =>
                              val == null || val.trim().isEmpty
                                  ? "Start date required"
                                  : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildField(
                      label: "End (MMM yyyy / Present)",
                      hintText: "e.g., Jun 2024",
                      controller: _eduEndDateController,
                      readOnly: true,
                      enabled: !_isCurrentEdu,
                      onTap:
                          _isCurrentEdu
                              ? null
                              : () => _pickDate(
                                _eduEndDateController,
                                "End (Month & Year)",
                              ),
                      validator: (val) {
                        if (_isCurrentEdu) return null;
                        return (val == null || val.trim().isEmpty)
                            ? "End date required"
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              // Toggle: I am currently studying here
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("I am currently studying here"),
                value: _isCurrentEdu,
                onChanged: (v) {
                  setState(() {
                    _isCurrentEdu = v ?? false;
                    if (_isCurrentEdu) {
                      _eduEndDateController.text = "Present";
                    } else {
                      _eduEndDateController.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 16),
              const Text(
                "Skills",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildField(
                label: "Add Skills (comma, semicolon, or newline separated)",
                controller: _skillsController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                validator:
                    (val) =>
                        val == null || val.trim().isEmpty
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

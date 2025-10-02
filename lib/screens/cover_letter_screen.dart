import 'package:cv_helper_app/screens/results_screen.dart';
import 'package:flutter/material.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobDescriptionController = TextEditingController();

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  void _generateLetter() {
    if (!_formKey.currentState!.validate()) return;

    final title = _jobTitleController.text.trim();
    final company = _companyController.text.trim();
    final desc = _jobDescriptionController.text.trim();

    final dummyLetter = """
Dear Hiring Manager,

I am excited to apply for the $title role at $company.
With my background and skills, I believe I am an excellent fit for this opportunity.

Job Description Highlights:
$desc

Thank you for considering my application.
I look forward to the opportunity to contribute to your team.

Sincerely,
[Your Name]

(This is a sample letter. Later, AI will generate a polished, tailored version.)
""";

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(resultText: dummyLetter)),
    );
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // rectangular vibe
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Cover Letter"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _jobTitleController,
                textInputAction: TextInputAction.next,
                decoration: _decoration("Job Title"),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                textInputAction: TextInputAction.next,
                decoration: _decoration("Company Name"),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jobDescriptionController,
                minLines: 5,
                maxLines: 10,
                decoration: _decoration(
                  "Job Description / Requirements",
                  hint: "Paste key responsibilities or the JD here…",
                ),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _generateLetter,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text("Generate Cover Letter"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

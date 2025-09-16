import 'package:cv_helper_app/screens/results_screen.dart';
import 'package:flutter/material.dart';


class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobDescriptionController = TextEditingController();

  void _generateLetter() {
    if (_jobTitleController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _jobDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final dummyLetter = """
Dear Hiring Manager,

I am excited to apply for the ${_jobTitleController.text} role at ${_companyController.text}. 
With my background and skills, I believe I am an excellent fit for this opportunity. 

Job Description Highlights:
${_jobDescriptionController.text}

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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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
      appBar: AppBar(title: const Text("Cover Letter"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildField(label: "Job Title", controller: _jobTitleController),
            _buildField(label: "Company Name", controller: _companyController),
            _buildField(
              label: "Job Description / Requirements",
              controller: _jobDescriptionController,
              maxLines: 5,
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
                onPressed: _generateLetter,
                child: const Text(
                  "Generate Cover Letter",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

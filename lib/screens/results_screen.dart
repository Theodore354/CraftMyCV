import 'package:flutter/material.dart';
import '../cv_storage.dart';
import 'my_cvs_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String resultText;

  const ResultsScreen({super.key, required this.resultText});

  Future<void> _saveCv(BuildContext context) async {
    await CvStorage.add(resultText);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("CV saved successfully!")));
    }
  }

  void _viewSavedCvs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyCvsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("CV Result"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            resultText,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _saveCv(context),
                icon: const Icon(Icons.save),
                label: const Text("Save CV"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _viewSavedCvs(context),
                icon: const Icon(Icons.folder_open),
                label: const Text("My CVs"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

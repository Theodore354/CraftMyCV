// lib/screens/results_screen.dart
import 'package:cv_helper_app/services/pdf_service.dart';
import 'package:flutter/material.dart';
import '../cv_storage.dart';
import 'my_cvs_screen.dart';


class ResultsScreen extends StatelessWidget {
  final String resultText;

  const ResultsScreen({super.key, required this.resultText});

  Future<void> _saveCv(BuildContext context) async {
    final currentList = CvStorage.savedCvs.value;

    if (!currentList.contains(resultText)) {
      await CvStorage.add(resultText);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CV saved successfully.')));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CV already saved.')));
      }
    }
  }

  Future<void> _saveAndGoToMyCvs(BuildContext context) async {
    final currentList = CvStorage.savedCvs.value;

    if (!currentList.contains(resultText)) {
      await CvStorage.add(resultText);
    }

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyCvsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Result'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            resultText.isNotEmpty
                ? resultText
                : "⚠️ No CV generated. Please create one first.",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Full-width Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _saveCv(context),
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
            const SizedBox(height: 10),

            // Row with two secondary buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _saveAndGoToMyCvs(context),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Save & View My CVs'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => PdfService.previewPdf(resultText),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Export PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

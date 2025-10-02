
import 'package:cv_helper_app/cv_storage.dart';
import 'package:cv_helper_app/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String resultText;

  const ResultsScreen({super.key, required this.resultText});

  Future<void> _saveCv(BuildContext context) async {
    final currentList = CvStorage.savedCvs.value;

    if (!currentList.contains(resultText)) {
      await CvStorage.add(resultText);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV saved successfully.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CV already saved.')));
    }
  }

  Future<void> _saveAndGoToMyCvs(BuildContext context) async {
    final currentList = CvStorage.savedCvs.value;

    if (!currentList.contains(resultText)) {
      await CvStorage.add(resultText);
    }

    // Replace stack and show MainScreen with "My CVs" tab selected
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 1)),
      (route) => false,
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    if (resultText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to copy.')));
      return;
    }
    await Clipboard.setData(ClipboardData(text: resultText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final hasText = resultText.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CV Result'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_outlined),
            onPressed: hasText ? () => _copyToClipboard(context) : null,
          ),
          IconButton(
            tooltip: 'Home',
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            hasText
                ? resultText
                : "⚠️ No CV generated. Please create one first.",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _saveAndGoToMyCvs(context),
                icon: const Icon(Icons.folder_open),
                label: const Text(' View My CVs'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    hasText ? () => PdfService.previewPdf(resultText) : null,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          hasText
              ? FloatingActionButton.extended(
                onPressed: () => _saveCv(context),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save'),
              )
              : null,
    );
  }
}

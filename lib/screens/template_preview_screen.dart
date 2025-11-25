import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cv_helper_app/models/index.dart';
import 'package:cv_helper_app/services/pdf_service.dart';

class TemplatePreviewScreen extends StatelessWidget {
  final CvModel cv;
  final String templateId;
  final String title;

  const TemplatePreviewScreen({
    super.key,
    required this.cv,
    required this.templateId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: "Export PDF",
            onPressed:
                () => PdfService.previewPdfFromCv(cv, templateId: templateId),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: PdfPreview(
        build:
            (format) =>
                PdfService.generatePdfFromCv(cv, templateId: templateId),
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: "${cv.fullName}_${templateId}.pdf",
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, {
                  "templateId": templateId,
                  "category": "cv",
                  "title": title,
                });
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "Use this template",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

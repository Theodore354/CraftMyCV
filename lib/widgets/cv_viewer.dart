import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class CvViewer extends StatelessWidget {
  final File? pdfFile;
  final String? plainText;
  const CvViewer({super.key, this.pdfFile, this.plainText});

  @override
  Widget build(BuildContext context) {
    if (pdfFile != null) {
      return FutureBuilder<PdfDocument>(
        future: PdfDocument.openFile(pdfFile!.path),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Could not open PDF.'));
          }

          // ✅ FIX: wrap document in Future.value()
          final controller = PdfController(document: Future.value(snap.data!));

          return PdfView(controller: controller);
        },
      );
    }

    // Fallback to plain text preview
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Text(
        (plainText ?? '').isEmpty ? 'No preview available.' : plainText!,
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  // Generate a PDF from CV text
  static Future<Uint8List> generatePdf(String cvText) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Text(cvText, style: pw.TextStyle(fontSize: 14)),
            ),
      ),
    );

    return pdf.save();
  }

  // Preview and print/share the PDF
  static Future<void> previewPdf(String cvText) async {
    final pdfData = await generatePdf(cvText);
    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }
}

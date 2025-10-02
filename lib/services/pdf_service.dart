import 'dart:typed_data';
import 'package:pdf/pdf.dart' show PdfColors;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cv_helper_app/models/index.dart';

class PdfService {
  // --- keep your original text-based generator (handy for quick debug) ---
  static Future<Uint8List> generatePdf(String cvText) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Text(cvText, style: const pw.TextStyle(fontSize: 14)),
            ),
      ),
    );
    return pdf.save();
  }

  static Future<void> previewPdf(String cvText) async {
    final pdfData = await generatePdf(cvText);
    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  // --- structured PDF from CvModel (clean sections & bullets) ---
  static Future<Uint8List> generatePdfFromCv(CvModel cv) async {
    final pdf = pw.Document();

    pw.Widget sectionTitle(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );

    pw.Widget bullet(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [pw.Text('•  '), pw.Expanded(child: pw.Text(text))],
      ),
    );

    // Header
    final header = pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (cv.email.isNotEmpty) pw.Text(cv.email),
              if (cv.phone.isNotEmpty) pw.Text('• ${cv.phone}'),
              if (cv.location.isNotEmpty) pw.Text('• ${cv.location}'),
            ],
          ),
        ],
      ),
    );

    // Work Experience
    final work =
        cv.workExperience.isEmpty
            ? pw.SizedBox()
            : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Work Experience'),
                ...cv.workExperience.map((w) {
                  final bullets = _splitBullets(w.responsibilities);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${w.jobTitle} — ${w.company}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${w.start} — ${w.end}',
                          style: const pw.TextStyle(color: PdfColors.grey700),
                        ),
                        if (bullets.isNotEmpty) pw.SizedBox(height: 4),
                        if (bullets.isNotEmpty) ...bullets.map(bullet),
                      ],
                    ),
                  );
                }),
              ],
            );

    // Education
    final edu =
        cv.education.isEmpty
            ? pw.SizedBox()
            : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Education'),
                ...cv.education.map((e) {
                  final bullets = _splitBullets(e.description);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${e.degree} — ${e.institution}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          '${e.start} — ${e.end}',
                          style: const pw.TextStyle(color: PdfColors.grey700),
                        ),
                        if (bullets.isNotEmpty) pw.SizedBox(height: 4),
                        if (bullets.isNotEmpty) ...bullets.map(bullet),
                      ],
                    ),
                  );
                }),
              ],
            );

    // Skills
    final skills =
        cv.skills.isEmpty
            ? pw.SizedBox()
            : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                sectionTitle('Skills'),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      cv.skills
                          .map(
                            (s) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey400),
                                borderRadius: pw.BorderRadius.circular(6),
                              ),
                              child: pw.Text(s),
                            ),
                          )
                          .toList(),
                ),
              ],
            );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        build:
            (ctx) => [
              header,
              pw.SizedBox(height: 12),
              work,
              if (cv.workExperience.isNotEmpty &&
                  (cv.education.isNotEmpty || cv.skills.isNotEmpty))
                pw.SizedBox(height: 12),
              edu,
              if (cv.education.isNotEmpty && cv.skills.isNotEmpty)
                pw.SizedBox(height: 12),
              skills,
            ],
      ),
    );

    return pdf.save();
  }

  static Future<void> previewPdfFromCv(CvModel cv) async {
    final pdfData = await generatePdfFromCv(cv);
    await Printing.layoutPdf(onLayout: (_) => pdfData);
  }

  // Helpers (same splitting logic as your preview screen)
  static List<String> _splitBullets(String? text) {
    if (text == null) return const [];
    final raw = text.trim();
    if (raw.isEmpty) return const [];
    return raw
        .split(RegExp(r'[\n;]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

import 'dart:typed_data';

import 'package:cv_helper_app/models/index.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<Uint8List> generatePdf(String cvText) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build:
            (context) => pw.Padding(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Text(cvText, style: const pw.TextStyle(fontSize: 14)),
            ),
      ),
    );
    return doc.save();
  }

  static Future<void> previewPdf(String cvText) async {
    final pdfData = await generatePdf(cvText);
    await Printing.layoutPdf(
      onLayout: (_) => pdfData,
      format: pdf.PdfPageFormat.a4,
    );
  }

  static Future<Uint8List> generatePdfFromText(
    String text, {
    String templateId = "default",
    String title = "Polished CV",
  }) async {
    final doc = pw.Document();
    final style = _textStyle(templateId);

    doc.addPage(
      pw.MultiPage(
        pageFormat: pdf.PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build:
            (ctx) => [
              // header strip
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: style.bg,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 42,
                      decoration: pw.BoxDecoration(
                        color: style.accent,
                        borderRadius: pw.BorderRadius.circular(999),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: style.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                text,
                style: pw.TextStyle(
                  fontSize: 12.5,
                  height: 1.4,
                  color: pdf.PdfColors.black,
                ),
              ),
            ],
      ),
    );

    return doc.save();
  }

  static Future<void> previewPdfFromText(
    String text, {
    String templateId = "default",
    String title = "Polished CV",
  }) async {
    final pdfBytes = await generatePdfFromText(
      text,
      templateId: templateId,
      title: title,
    );
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      format: pdf.PdfPageFormat.a4,
    );
  }

  static Future<Uint8List> generatePdfFromCv(
    CvModel cv, {
    String templateId = "default",
  }) async {
    final doc = pw.Document();

    switch (templateId) {
      case "modern_cv":
        doc.addPage(_modernTemplate(cv));
        break;
      case "minimal_cv":
        doc.addPage(_minimalTemplate(cv));
        break;
      default:
        doc.addPage(_defaultTemplate(cv));
        break;
    }

    return doc.save();
  }

  static Future<void> previewPdfFromCv(
    CvModel cv, {
    String templateId = "default",
  }) async {
    final bytes = await generatePdfFromCv(cv, templateId: templateId);
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      format: pdf.PdfPageFormat.a4,
    );
  }

  // ============================================================
  // ✅ TEMPLATE IMPLEMENTATIONS
  // ============================================================

  static pw.MultiPage _defaultTemplate(CvModel cv) {
    return pw.MultiPage(
      pageFormat: pdf.PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build:
          (ctx) => [
            _headerBlock(
              cv,
              bg: pdf.PdfColors.grey200,
              accent: pdf.PdfColors.blueGrey900,
            ),
            pw.SizedBox(height: 12),
            _workSection(cv, accent: pdf.PdfColors.blueGrey900),
            _eduSection(cv, accent: pdf.PdfColors.blueGrey900),
            _skillsSection(cv, accent: pdf.PdfColors.blueGrey900),
          ],
    );
  }

  /// ✅ MODERN TEMPLATE (best first impression)
  static pw.MultiPage _modernTemplate(CvModel cv) {
    const accent = pdf.PdfColors.blue800;

    return pw.MultiPage(
      pageFormat: pdf.PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build:
          (ctx) => [
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [pdf.PdfColors.blue700, pdf.PdfColors.blue300],
                ),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    cv.fullName.isEmpty ? "Your Name" : cv.fullName,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: pdf.PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (cv.email.isNotEmpty)
                        pw.Text(
                          cv.email,
                          style: const pw.TextStyle(color: pdf.PdfColors.white),
                        ),
                      if (cv.phone.isNotEmpty)
                        pw.Text(
                          "• ${cv.phone}",
                          style: const pw.TextStyle(color: pdf.PdfColors.white),
                        ),
                      if (cv.location.isNotEmpty)
                        pw.Text(
                          "• ${cv.location}",
                          style: const pw.TextStyle(color: pdf.PdfColors.white),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            _workSection(cv, accent: accent),
            _eduSection(cv, accent: accent),
            _skillsSection(cv, accent: accent),
          ],
    );
  }

  /// ✅ MINIMAL TEMPLATE (ATS-friendly + clean)
  static pw.MultiPage _minimalTemplate(CvModel cv) {
    return pw.MultiPage(
      pageFormat: pdf.PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 24),
      build:
          (ctx) => [
            pw.Text(
              cv.fullName.isEmpty ? "Your Name" : cv.fullName,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              [
                cv.email,
                cv.phone,
                cv.location,
              ].where((e) => e.trim().isNotEmpty).join(" • "),
              style: const pw.TextStyle(
                color: pdf.PdfColors.grey700,
                fontSize: 11,
              ),
            ),
            pw.SizedBox(height: 14),
            _workSection(cv, accent: pdf.PdfColors.black),
            _eduSection(cv, accent: pdf.PdfColors.black),
            _skillsSection(cv, accent: pdf.PdfColors.black),
          ],
    );
  }

  static pw.Widget _headerBlock(
    CvModel cv, {
    required pdf.PdfColor bg,
    required pdf.PdfColor accent,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: bg,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: pdf.PdfColors.black,
            ),
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
  }

  static pw.Widget _sectionTitle(String text, pdf.PdfColor accent) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: accent,
          ),
        ),
      );

  static pw.Widget _bullet(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [pw.Text('•  '), pw.Expanded(child: pw.Text(text))],
    ),
  );

  static pw.Widget _workSection(CvModel cv, {required pdf.PdfColor accent}) {
    if (cv.workExperience.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Work Experience', accent),
        ...cv.workExperience.map((w) {
          final bullets = _splitBullets(w.responsibilities);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${w.jobTitle} — ${w.company}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  '${w.start} — ${w.end}',
                  style: const pw.TextStyle(color: pdf.PdfColors.grey700),
                ),
                if (bullets.isNotEmpty) pw.SizedBox(height: 4),
                if (bullets.isNotEmpty) ...bullets.map(_bullet),
              ],
            ),
          );
        }),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _eduSection(CvModel cv, {required pdf.PdfColor accent}) {
    if (cv.education.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Education', accent),
        ...cv.education.map((e) {
          final bullets = _splitBullets(e.description);
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${e.degree} — ${e.institution}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  '${e.start} — ${e.end}',
                  style: const pw.TextStyle(color: pdf.PdfColors.grey700),
                ),
                if (bullets.isNotEmpty) pw.SizedBox(height: 4),
                if (bullets.isNotEmpty) ...bullets.map(_bullet),
              ],
            ),
          );
        }),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _skillsSection(CvModel cv, {required pdf.PdfColor accent}) {
    if (cv.skills.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Skills', accent),
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
                        border: pw.Border.all(color: pdf.PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(s),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

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

  // ============================================================
  // Text template styles for polished CV PDFs
  // ============================================================

  static _TextStylePack _textStyle(String templateId) {
    switch (templateId) {
      case "modern_cv":
        return const _TextStylePack(
          accent: pdf.PdfColors.blue800,
          bg: pdf.PdfColors.blue50,
          textColor: pdf.PdfColors.blue900,
        );
      case "minimal_cv":
        return const _TextStylePack(
          accent: pdf.PdfColors.black,
          bg: pdf.PdfColors.grey100,
          textColor: pdf.PdfColors.black,
        );
      default:
        return const _TextStylePack(
          accent: pdf.PdfColors.blueGrey900,
          bg: pdf.PdfColors.grey200,
          textColor: pdf.PdfColors.black,
        );
    }
  }
}

class _TextStylePack {
  final pdf.PdfColor accent;
  final pdf.PdfColor bg;
  final pdf.PdfColor textColor;

  const _TextStylePack({
    required this.accent,
    required this.bg,
    required this.textColor,
  });
}

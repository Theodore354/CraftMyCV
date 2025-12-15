import 'package:cv_helper_app/cv_storage.dart';
import 'package:cv_helper_app/services/pdf_service.dart';
import 'package:cv_helper_app/screens/templates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_screen.dart';

class ResultsScreen extends StatelessWidget {
  /// Summary / generic result (used for cover letter or AI change summary)
  final String resultText;

  /// Optional: raw CV text before polishing (for before/after UI)
  final String? beforeText;

  /// Optional: polished full CV text (for template export + after UI)
  final String? polishedText;

  /// Optional: show template export buttons when polishedText exists
  final bool allowTemplateExport;

  /// Optional: custom title (shown in AppBar)
  final String title;

  const ResultsScreen({
    super.key,
    required this.resultText,
    this.beforeText,
    this.polishedText,
    this.allowTemplateExport = false,
    this.title = 'CV Result',
  });

  bool get _hasText =>
      (polishedText?.trim().isNotEmpty ?? false) ||
      resultText.trim().isNotEmpty;

  /// We save polishedText if it exists; otherwise save resultText.
  String get _saveText =>
      (polishedText?.trim().isNotEmpty ?? false) ? polishedText! : resultText;

  Future<void> _saveCv(BuildContext context) async {
    final currentList = CvStorage.savedCvs.value;

    if (!currentList.contains(_saveText)) {
      await CvStorage.add(_saveText);
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
    if (!currentList.contains(_saveText)) {
      await CvStorage.add(_saveText);
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 1)),
      (route) => false,
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    if (!_hasText) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nothing to copy.')));
      return;
    }

    await Clipboard.setData(ClipboardData(text: _saveText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  Future<void> _exportStyledFromTemplates(BuildContext context) async {
    if (polishedText == null || polishedText!.trim().isEmpty) return;

    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const TemplatesScreen()),
    );

    if (selected == null) return;

    final templateId = selected["templateId"]?.toString() ?? "default";
    final templateTitle = selected["title"]?.toString() ?? "Template";

    await PdfService.previewPdfFromText(
      polishedText!,
      templateId: templateId,
      title: templateTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final showBeforeAfter =
        beforeText != null &&
        beforeText!.trim().isNotEmpty &&
        polishedText != null &&
        polishedText!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_outlined),
            onPressed: _hasText ? () => _copyToClipboard(context) : null,
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

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Refined Header Card (no big "Polished CV" text) =====
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.primary.withOpacity(.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: scheme.primary.withOpacity(.12),
                  child: Icon(Icons.auto_fix_high, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "All set ✨",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Review the AI result below. You can save, copy, or export it as a PDF.",
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ===== Before vs After =====
          if (showBeforeAfter) ...[
            const _SectionTitle(
              icon: Icons.compare_arrows,
              title: "Before vs After",
            ),
            const SizedBox(height: 8),

            _BeforeAfterCard(beforeText: beforeText!, afterText: polishedText!),

            const SizedBox(height: 18),
          ],

          // ===== Polished / Final CV Text =====
          if (polishedText != null && polishedText!.trim().isNotEmpty) ...[
            const _SectionTitle(
              icon: Icons.check_circle_outline,
              title: "Polished version",
            ),
            const SizedBox(height: 8),

            _TextCard(text: polishedText!, tone: "after"),

            const SizedBox(height: 18),
          ],

          // ===== Summary / Generic Result =====
          if (resultText.trim().isNotEmpty) ...[
            const _SectionTitle(
              icon: Icons.lightbulb_outline,
              title: "AI summary",
            ),
            const SizedBox(height: 8),

            _TextCard(text: resultText, tone: "summary"),
          ],

          if (!_hasText)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  "⚠️ No result generated. Please try again.",
                  style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
                ),
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),

      // ===== Bottom Actions =====
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _saveAndGoToMyCvs(context),
                      icon: const Icon(Icons.folder_open),
                      label: const Text('View My CVs'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _hasText
                              ? () => PdfService.previewPdf(_saveText)
                              : null,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export PDF'),
                    ),
                  ),
                ],
              ),

              // ✅ Template export for polished CV
              if (allowTemplateExport &&
                  polishedText != null &&
                  polishedText!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => _exportStyledFromTemplates(context),
                    icon: const Icon(Icons.layers_outlined),
                    label: const Text(
                      "Choose template & export",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      floatingActionButton:
          _hasText
              ? FloatingActionButton.extended(
                onPressed: () => _saveCv(context),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save'),
              )
              : null,
    );
  }
}

// ===== UI Components =====

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: scheme.primary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _TextCard extends StatelessWidget {
  final String text;
  final String tone; // "after" | "summary"
  const _TextCard({required this.text, required this.tone});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg =
        tone == "after"
            ? scheme.surfaceVariant.withOpacity(.45)
            : scheme.surface.withOpacity(.9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.6)),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(fontSize: 14.5, height: 1.55),
      ),
    );
  }
}

class _BeforeAfterCard extends StatelessWidget {
  final String beforeText;
  final String afterText;

  const _BeforeAfterCard({required this.beforeText, required this.afterText});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget side({
      required String label,
      required IconData icon,
      required Color tint,
      required String text,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tint.withOpacity(.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tint.withOpacity(.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: tint),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(fontWeight: FontWeight.w800, color: tint),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                text,
                style: const TextStyle(fontSize: 13.5, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        side(
          label: "Before",
          icon: Icons.history,
          tint: scheme.error,
          text: beforeText,
        ),
        const SizedBox(width: 10),
        side(
          label: "After",
          icon: Icons.auto_fix_high,
          tint: scheme.primary,
          text: afterText,
        ),
      ],
    );
  }
}

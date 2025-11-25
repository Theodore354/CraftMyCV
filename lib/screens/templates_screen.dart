import 'package:flutter/material.dart';
import 'package:cv_helper_app/models/index.dart';
import 'package:cv_helper_app/services/pdf_service.dart';

class TemplatesScreen extends StatefulWidget {
  final CvModel? cv;

  const TemplatesScreen({super.key, this.cv});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String? _selectedId;

  final _cvTemplates = const [
    {
      "id": "modern_cv",
      "title": "Modern CV",
      "subtitle": "Clean + colorful, great for tech roles",
      "accent": Color(0xFF1565C0),
    },
    {
      "id": "professional_cv",
      "title": "Professional CV",
      "subtitle": "Classic corporate look",
      "accent": Color(0xFF1B1B1B),
    },
    {
      "id": "creative_cv",
      "title": "Creative CV",
      "subtitle": "Bold + stylish, best for designers",
      "accent": Color(0xFF6A1B9A),
    },
    {
      "id": "minimal_cv",
      "title": "Minimal CV",
      "subtitle": "Simple, ATS-friendly",
      "accent": Color(0xFF000000),
    },
  ];

  Future<void> _confirmTemplate(Map<String, dynamic> t) async {
    final id = t["id"] as String;
    final title = t["title"] as String;

    setState(() => _selectedId = id);

    // ✅ If cv NOT provided, we are picking for ResultsScreen
    if (widget.cv == null) {
      Navigator.pop(context, {"templateId": id, "title": title});
      return;
    }

    // ✅ If cv provided, export structured CV in template
    await PdfService.previewPdfFromCv(widget.cv!, templateId: id);
  }

  void _openPreviewSheet(Map<String, dynamic> t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _TemplatePreviewSheet(
          template: t,
          onUse: () async {
            Navigator.pop(context); // close sheet
            await _confirmTemplate(t);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Templates"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "CV Templates",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            widget.cv == null
                ? "Choose a style for your polished CV."
                : "Pick a template to preview/export your CV.",
            style: TextStyle(color: scheme.outline),
          ),
          const SizedBox(height: 14),

          GridView.builder(
            itemCount: _cvTemplates.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, i) {
              final t = _cvTemplates[i];
              final id = t["id"] as String;
              final selected = id == _selectedId;

              return _TemplateCard(
                title: t["title"] as String,
                subtitle: t["subtitle"] as String,
                accent: t["accent"] as Color,
                selected: selected,
                onTap: () => _openPreviewSheet(t),
              );
            },
          ),

          const SizedBox(height: 26),
          Text(
            "Cover Letter Templates",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "Coming next — Cover Letters will have styled templates too.",
            style: TextStyle(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(.08) : scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : scheme.outlineVariant.withOpacity(.6),
              width: selected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // mini preview thumbnail
              _MiniCvPreview(accent: accent),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.outline,
                  height: 1.25,
                ),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Preview",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 12, color: accent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCvPreview extends StatelessWidget {
  final Color accent;
  const _MiniCvPreview({required this.accent});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 92,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header bar
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accent.withOpacity(.9),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 6),

          // fake text lines
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                height: 6,
                width: i.isEven ? 70 : 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplatePreviewSheet extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onUse;

  const _TemplatePreviewSheet({required this.template, required this.onUse});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = template["accent"] as Color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            template["title"] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            template["subtitle"] as String,
            style: TextStyle(color: scheme.outline),
          ),
          const SizedBox(height: 14),

          // Bigger preview
          Container(
            height: 220,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant.withOpacity(.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  10,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      height: 8,
                      width: i.isEven ? 180 : 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: onUse,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                "Use This Template",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ),
        ],
      ),
    );
  }
}

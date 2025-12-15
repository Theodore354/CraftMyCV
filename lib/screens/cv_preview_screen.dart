import 'package:flutter/material.dart';
import 'package:cv_helper_app/models/index.dart';
import 'package:cv_helper_app/services/pdf_service.dart';
import 'package:cv_helper_app/screens/templates_screen.dart';
import 'package:cv_helper_app/services/ai_service.dart';
import 'package:cv_helper_app/models/polish_profile.dart';
import 'package:cv_helper_app/screens/results_screen.dart';
import 'package:cv_helper_app/utils/cv_text_formatter.dart';

class CvPreviewScreen extends StatefulWidget {
  final CvModel cv;
  const CvPreviewScreen({super.key, required this.cv});

  @override
  State<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends State<CvPreviewScreen> {
  bool _enhancing = false;

  CvModel get cv => widget.cv;

  Future<void> _confirmAndPickTemplate(BuildContext context) async {
    // Open templates screen and wait for user selection
    final selected = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => TemplatesScreen(cv: cv)),
    );

    if (!context.mounted) return;

    // fallback if user backs out
    final result =
        selected ??
        {
          "templateId": "default",
          "category": "cv",
          "title": "Default Template",
        };

    // Return Map to previous screen
    Navigator.of(context).pop(result);
  }

  /// Apply AI suggestions on top of the raw text (simple replaceFirst pass)
  String _applyChanges(String raw, List changes) {
    var text = raw;
    for (final dynamic c in changes) {
      // AiService already returns List<ChangeSuggestion>,
      // but we keep it dynamic-safe here.
      final before = c.before.trim();
      final after = c.after.trim();
      if (before.isEmpty || after.isEmpty) continue;
      if (text.contains(before)) {
        text = text.replaceFirst(before, after);
      }
    }
    return text;
  }

  Future<void> _enhanceWithAi() async {
    if (_enhancing) return;

    final rawText = cvToPlainText(cv);
    if (rawText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your CV details first.')),
      );
      return;
    }

    setState(() => _enhancing = true);

    try {
      // Basic default profile – later you could let the user tweak this.
      final profile = PolishProfile(
        role:
            cv.workExperience.isNotEmpty
                ? cv.workExperience.first.jobTitle
                : 'Graduate',
        industry: 'General/Tech',
        seniority: 'Entry-level',
        tone: 'Concise & professional',
        options: const ['ATS_optimize', 'Metrics_focus'],
      );

      final suggestions = await AiService.draftChanges(
        rawText: rawText,
        profile: profile,
        areas: const ['Summary', 'Experience', 'Education', 'Skills'],
        userInstruction: 'General polish for job applications',
      );

      if (!mounted) return;

      final polishedText = _applyChanges(rawText, suggestions);

      // Navigate to ResultsScreen with before/after + template export
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultsScreen(
                title: 'AI-Enhanced CV',
                beforeText: rawText,
                polishedText: polishedText,
                resultText:
                    'Your CV has been polished based on your target role and industry.',
                allowTemplateExport:
                    true, // enables "Choose Template & Export" button
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to enhance CV: $e')));
    } finally {
      if (mounted) setState(() => _enhancing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        actions: [
          IconButton(
            tooltip: 'Export PDF',
            onPressed: () => PdfService.previewPdfFromCv(cv),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActions(
        onEdit: () => Navigator.of(context).pop(false),
        onConfirm: () => _confirmAndPickTemplate(context),
        onEnhance: _enhanceWithAi,
        enhancing: _enhancing,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _InitialsAvatar(name: cv.fullName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
                        style: textTheme.headlineSmall?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (cv.email.isNotEmpty)
                      _ContactPill(icon: Icons.mail_outline, text: cv.email),
                    if (cv.phone.isNotEmpty)
                      _ContactPill(icon: Icons.phone_iphone, text: cv.phone),
                    if (cv.location.isNotEmpty)
                      _ContactPill(
                        icon: Icons.location_on_outlined,
                        text: cv.location,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Small hint about AI enhancement
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(Icons.auto_fix_high, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Review your CV below. You can enhance the wording with AI before choosing a template.',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (cv.workExperience.isNotEmpty)
                  _Section(
                    title: 'Work Experience',
                    child: Column(
                      children: [
                        for (final w in cv.workExperience)
                          _BlockCard(
                            leadingIcon: Icons.work_outline,
                            title: '${w.jobTitle} — ${w.company}',
                            subtitle: '${w.start} — ${w.end}',
                            bullets: _splitBullets(w.responsibilities),
                          ),
                      ],
                    ),
                  ),

                if (cv.education.isNotEmpty)
                  _Section(
                    title: 'Education',
                    child: Column(
                      children: [
                        for (final e in cv.education)
                          _BlockCard(
                            leadingIcon: Icons.school_outlined,
                            title: '${e.degree} — ${e.institution}',
                            subtitle: '${e.start} — ${e.end}',
                            bullets: _splitBullets(e.description),
                          ),
                      ],
                    ),
                  ),

                if (cv.skills.isNotEmpty)
                  _Section(
                    title: 'Skills',
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            cv.skills.map((s) => Chip(label: Text(s))).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 84),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final VoidCallback onEnhance;
  final bool enhancing;

  const _BottomActions({
    required this.onEdit,
    required this.onConfirm,
    required this.onEnhance,
    required this.enhancing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(color: scheme.outlineVariant.withOpacity(.5)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: enhancing ? null : onEnhance,
                icon:
                    enhancing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.auto_fix_high),
                label: Text(enhancing ? 'Enhancing…' : 'Enhance with AI'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: scheme.primary, width: 1),
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      elevation: 0,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    child: const Text('Confirm & Save'),
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 1,
                  color: scheme.outlineVariant.withOpacity(.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final List<String> bullets;

  const _BlockCard({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(leadingIcon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
                if (bullets.isNotEmpty) const SizedBox(height: 8),
                if (bullets.isNotEmpty)
                  Column(
                    children:
                        bullets
                            .map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('•  '),
                                    Expanded(child: Text(b)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onPrimary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 12.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;
  const _InitialsAvatar({required this.name});

  String _initials(String s) {
    final parts =
        s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '👤';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 22,
      backgroundColor: scheme.onPrimary.withOpacity(.15),
      child: Text(
        _initials(name),
        style: TextStyle(color: scheme.onPrimary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

List<String> _splitBullets(String? text) {
  if (text == null) return const [];
  final raw = text.trim();
  if (raw.isEmpty) return const [];
  return raw
      .split(RegExp(r'[\n;]+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

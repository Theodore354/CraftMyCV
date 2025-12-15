import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:cv_helper_app/models/index.dart';
import 'package:cv_helper_app/services/ai_service.dart';
import 'package:cv_helper_app/screens/review_changes_screen.dart';
import 'package:cv_helper_app/screens/results_screen.dart';
import 'package:cv_helper_app/widgets/cv_viewer.dart';

class PolishCVScreen extends StatefulWidget {
  const PolishCVScreen({super.key});
  @override
  State<PolishCVScreen> createState() => _PolishCVScreenState();
}

class _PolishCVScreenState extends State<PolishCVScreen> {
  PlatformFile? _file;
  File? _pdfLocal;
  bool _picking = false;
  bool _loading = false;

  final _improvementController = TextEditingController();
  final _pasteController = TextEditingController();

  // Polish profile
  String _role = 'Software Engineer';
  String _industry = 'General/Tech';
  String _seniority = 'Mid-level';
  String _tone = 'Concise & professional';
  final Set<String> _options = {'ATS_optimize', 'Metrics_focus'};

  // Areas to improve
  final Set<String> _areas = {'Summary', 'Experience', 'Skills'};

  @override
  void dispose() {
    _improvementController.dispose();
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      setState(() => _picking = true);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final f = result.files.single;
        setState(() {
          _file = f;
          _pdfLocal =
              (f.extension?.toLowerCase() == 'pdf' && f.path != null)
                  ? File(f.path!)
                  : null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File pick failed: $e')));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _removeFile() => setState(() {
    _file = null;
    _pdfLocal = null;
  });

  bool get _hasInput =>
      _file != null || _pasteController.text.trim().isNotEmpty;

  String _fmtBytes(int? bytes) {
    if (bytes == null) return '';
    const sizes = ['B', 'KB', 'MB', 'GB'];
    var len = bytes.toDouble();
    var order = 0;
    while (len >= 1024 && order < sizes.length - 1) {
      order++;
      len /= 1024;
    }
    return '${len.toStringAsFixed(1)} ${sizes[order]}';
  }

  Widget _optionChip(String key) {
    final selected = _options.contains(key);
    return FilterChip(
      selected: selected,
      label: Text(key.replaceAll('_', ' ')),
      onSelected:
          (_) => setState(() {
            if (selected) {
              _options.remove(key);
            } else {
              _options.add(key);
            }
          }),
    );
  }

  // ✅ best-effort apply: replace "before" with "after" sequentially
  String _applyChanges(String raw, List<ChangeSuggestion> accepted) {
    var text = raw;
    for (final c in accepted) {
      final before = c.before.trim();
      final after = c.after.trim();
      if (before.isEmpty || after.isEmpty) continue;

      if (text.contains(before)) {
        text = text.replaceFirst(before, after);
      }
    }
    return text;
  }

  Future<void> _onPolish() async {
    final pasted = _pasteController.text.trim();
    final improve = _improvementController.text.trim();

    if (!_hasInput) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a CV or paste text first')),
      );
      return;
    }

    // This is the "before" text we send to AI and show in ResultsScreen
    final rawText =
        pasted.isNotEmpty ? pasted : '[[PDF content not parsed yet]]';

    final profile = PolishProfile(
      role: _role,
      industry: _industry,
      seniority: _seniority,
      tone: _tone,
      options: _options.toList(),
    );

    setState(() => _loading = true);

    try {
      final suggestions = await AiService.draftChanges(
        rawText: rawText,
        profile: profile,
        areas: _areas.toList(),
        userInstruction: improve.isEmpty ? 'General polish' : improve,
      );
      if (!mounted) return;

      // Let user review/accept changes
      final accepted = await Navigator.push<List<ChangeSuggestion>>(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewChangesScreen(suggestions: suggestions),
        ),
      );
      if (!mounted || accepted == null) return;

      // ✅ Apply only accepted changes
      final polishedText = _applyChanges(rawText, accepted);

      // Build AI summary text
      final summary =
          StringBuffer()
            ..writeln('AI CV Polisher — Proposed changes')
            ..writeln(
              'Role: ${profile.role} | Industry: ${profile.industry} | ${profile.seniority}',
            )
            ..writeln(
              'Tone: ${profile.tone} | Options: ${profile.options.join(", ")}',
            )
            ..writeln('\nAccepted changes:\n');

      for (final c in accepted) {
        summary
          ..writeln('— Scope: ${c.scope}')
          ..writeln('   Before: ${c.before}')
          ..writeln('   After : ${c.after}')
          ..writeln('   Why   : ${c.rationale}\n');
      }

      // ✅ Send both BEFORE + AFTER to ResultsScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResultsScreen(
                title: "Polished CV",
                beforeText: rawText,
                polishedText: polishedText,
                resultText: summary.toString(),
                allowTemplateExport: true,
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Polish failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhance CV'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Simple header text =====
            Text(
              'Enhance your existing CV',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Upload your CV or paste the text, then let AI help you clean up the wording and structure.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // ===== Upload section =====
            Text(
              'Upload your CV',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF or Word (DOC/DOCX) supported.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: _picking ? null : _pickFile,
              child: DottedBorder(
                color: Colors.blueGrey.shade300,
                strokeWidth: 1.6,
                dashPattern: const [7, 7],
                borderType: BorderType.RRect,
                radius: const Radius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.cardColor,
                  ),
                  child:
                      _file == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                size: 32,
                                color: scheme.primary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to upload your CV',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _picking
                                    ? 'Opening file picker…'
                                    : 'We’ll keep your file on-device and only send text to AI.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 130,
                                ),
                                child: ElevatedButton(
                                  onPressed: _picking ? null : _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: scheme.primaryContainer,
                                    foregroundColor: scheme.onPrimaryContainer,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                  ),
                                  child:
                                      _picking
                                          ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                          : const Text('Browse files'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Accepted: PDF, DOC, DOCX',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _file!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _fmtBytes(_file!.size),
                                      style: TextStyle(
                                        color: scheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _removeFile,
                                child: const Text('Remove'),
                              ),
                              const SizedBox(width: 4),
                              TextButton(
                                onPressed: _pickFile,
                                child: const Text('Change'),
                              ),
                            ],
                          ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // ===== Paste text =====
            Text(
              'Paste your CV text (optional)',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'If your file is not supported, just paste the content here.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pasteController,
              minLines: 6,
              maxLines: 12,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Paste your current CV text here…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 20),
            Text(
              'Tell us what to improve',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Be specific and the AI will focus on those areas first.',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _improvementController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'e.g., tailor to fintech, quantify impact, tighten summary',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Polish profile',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(labelText: 'Target role'),
                    items:
                        const [
                              'Software Engineer',
                              'Backend Engineer',
                              'Mobile Developer',
                              'Data Analyst',
                              'Product Manager',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _role = v ?? _role),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _industry,
                    decoration: const InputDecoration(labelText: 'Industry'),
                    items:
                        const [
                              'General/Tech',
                              'FinTech',
                              'HealthTech',
                              'E-commerce',
                              'EdTech',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged:
                        (v) => setState(() => _industry = v ?? _industry),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _seniority,
                    decoration: const InputDecoration(labelText: 'Seniority'),
                    items:
                        const ['Entry-level', 'Mid-level', 'Senior', 'Lead']
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged:
                        (v) => setState(() => _seniority = v ?? _seniority),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _tone,
                    decoration: const InputDecoration(labelText: 'Tone'),
                    items:
                        const [
                              'Concise & professional',
                              'Confident',
                              'Warm',
                              'Formal',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _tone = v ?? _tone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _optionChip('ATS_optimize'),
                _optionChip('Metrics_focus'),
                _optionChip('Leadership_emphasis'),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              'Select areas to improve',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                    'Summary',
                    'Experience',
                    'Education',
                    'Skills',
                    'Projects',
                  ].map((a) {
                    final selected = _areas.contains(a);
                    return FilterChip(
                      selected: selected,
                      label: Text(a),
                      onSelected:
                          (_) => setState(() {
                            if (selected) {
                              _areas.remove(a);
                            } else {
                              _areas.add(a);
                            }
                          }),
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),
            Text(
              'Live preview',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CvViewer(
                  pdfFile: _pdfLocal,
                  plainText: _pdfLocal == null ? _pasteController.text : null,
                ),
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _loading || !_hasInput ? null : _onPolish,
            child:
                _loading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Enhance with AI'),
          ),
        ),
      ),
    );
  }
}

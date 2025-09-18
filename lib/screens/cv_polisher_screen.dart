// lib/screens/cv_polisher_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'results_screen.dart';

class PolishCVScreen extends StatefulWidget {
  const PolishCVScreen({super.key});

  @override
  State<PolishCVScreen> createState() => _PolishCVScreenState();
}

class _PolishCVScreenState extends State<PolishCVScreen> {
  PlatformFile? _file;
  bool _picking = false;

  final _improvementController = TextEditingController();
  final _pasteController = TextEditingController();

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
        setState(() => _file = result.files.single);
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

  void _removeFile() => setState(() => _file = null);

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

  void _onPolish() {
    final pasted = _pasteController.text.trim();
    final improve = _improvementController.text.trim();

    if (_file == null && pasted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a CV or paste text first')),
      );
      return;
    }

    final srcLabel =
        _file != null
            ? 'Uploaded file: ${_file!.name} ${_fmtBytes(_file!.size)}'
            : 'Pasted text (${pasted.length} chars)';

    final focus =
        improve.isEmpty
            ? 'General polish (grammar, clarity, ATS keywords).'
            : improve;

    final polished = '''
AI CV Polisher — Preview

Source: $srcLabel
Requested focus: $focus

What will be improved:
• Sharpen the professional summary (impact-first).
• Quantify achievements with metrics where possible.
• Normalize tense/voice and reduce filler.
• Fix formatting (dates, bullets, spacing, consistency).
• Insert role-appropriate ATS keywords.

Sample reworded summary:
“Results-driven professional with 4+ years’ experience in [domain]. Improved [metric] by [X%] through [action]. Skilled in [tools/skills]. Seeking to drive impact at [target role/company].”

(Placeholder content — connect your AI next.)
''';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultsScreen(resultText: polished)),
    );
  }

  bool get _canPolish =>
      _file != null || _pasteController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Blue that matches the screenshot button
    const primaryBlue = Color(0xFF0A84FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Polish CV',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload your CV',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your existing CV in PDF or Word format to get started.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // === Dotted Upload Area ===
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
                    vertical: 36,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child:
                      _file == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Upload CV',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _picking
                                    ? 'Opening picker…'
                                    : 'Tap to upload your CV',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              // Small "Upload" pill button in the card
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 120,
                                ),
                                child: ElevatedButton(
                                  onPressed: _picking ? null : _pickFile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueGrey.shade50,
                                    foregroundColor: Colors.black87,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Upload'),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Accepted: PDF, DOC, DOCX',
                                style: TextStyle(color: Colors.black54),
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
                                    const SizedBox(height: 2),
                                    Text(
                                      _fmtBytes(_file!.size),
                                      style: const TextStyle(
                                        color: Colors.black54,
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

            // Paste CV text
            const Text(
              'Paste your CV text (optional)',
              style: TextStyle(fontWeight: FontWeight.w700),
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

            const SizedBox(height: 16),

            // Improvement focus
            const Text(
              'Specify areas for improvement',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _improvementController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., grammar, keywords, conciseness',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      // === Polish CV button to match UI ===
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _canPolish ? _onPolish : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 29, 138, 248),
              disabledBackgroundColor: Color.fromARGB(255, 10, 132, 255).withOpacity(0.9),
 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Polish CV'),
          ),
        ),
      ),
    );
  }
}

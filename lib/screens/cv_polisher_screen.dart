// lib/screens/cv_polisher_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
        withData: false, // we only need metadata here
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

    // Placeholder “polished” output for now — replace later with AI call
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

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your existing CV in PDF or Word format, or paste your CV text below.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Upload card
            InkWell(
              onTap: _picking ? null : _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blueGrey.shade200,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child:
                    _file == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.upload_file, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              _picking
                                  ? 'Opening picker…'
                                  : 'Tap to upload your CV',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pasteController,
              minLines: 6,
              maxLines: 12,
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
              'What should we improve?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _improvementController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'e.g., grammar, ATS keywords for Product Manager, conciseness',
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FilledButton(
          onPressed: _onPolish,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('Polish CV', style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

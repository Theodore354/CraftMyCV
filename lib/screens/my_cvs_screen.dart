import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cv_helper_app/cv_storage.dart';
import 'package:cv_helper_app/models/index.dart';
import 'results_screen.dart';
import 'cv_form_screen.dart';

class MyCvsScreen extends StatelessWidget {
  const MyCvsScreen({super.key});

  Future<void> _deleteCv(BuildContext context, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete CV?"),
            content: const Text("Are you sure you want to delete this CV?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await CvStorage.delete(index);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('CV deleted')));
      }
    }
  }

  bool _looksLikeJson(String s) {
    final t = s.trimLeft();
    return t.startsWith('{') || t.startsWith('[');
  }

  void _editCv(BuildContext context, int index, String raw) {
    if (!_looksLikeJson(raw)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This CV is in an older format and cannot be edited. '
            'Create a new one instead.',
          ),
        ),
      );
      return;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final cv = CvModel.fromJson(map);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CvFormScreen(initial: cv, storageIndex: index),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open CV for editing.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My CVs"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Clear All",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text("Clear All CVs?"),
                      content: const Text(
                        "This will permanently delete all saved CVs.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Delete All"),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await CvStorage.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All CVs cleared")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<String>>(
        valueListenable: CvStorage.savedCvs,
        builder: (context, cvs, _) {
          if (cvs.isEmpty) {
            return const Center(
              child: Text(
                "No CVs saved yet.\nGo create one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cvs.length,
            itemBuilder: (context, index) {
              final raw = cvs[index];

              String title;
              String previewPlainText;
              CvModel? parsed;

              if (_looksLikeJson(raw)) {
                try {
                  final map = jsonDecode(raw) as Map<String, dynamic>;
                  parsed = CvModel.fromJson(map);
                  title =
                      parsed.fullName.isEmpty ? "Untitled CV" : parsed.fullName;
                  previewPlainText = parsed.toPlainText();
                } catch (_) {
                  title = "Untitled CV";
                  previewPlainText = raw;
                }
              } else {
                final preview = raw.split("\n").first;
                title = preview.isNotEmpty ? preview : "Untitled CV";
                previewPlainText = raw;
              }

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Tap to view full CV"),
                  leading: const Icon(Icons.description_outlined),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit',
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editCv(context, index, raw),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCv(context, index),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Keep your ResultsScreen flow for viewing
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ResultsScreen(resultText: previewPlainText),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

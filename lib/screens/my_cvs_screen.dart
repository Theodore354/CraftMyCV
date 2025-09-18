// lib/screens/my_cvs_screen.dart
import 'package:flutter/material.dart';
import '../cv_storage.dart';
import 'results_screen.dart';

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
              final preview = cvs[index].split("\n").first;
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
                    preview.isNotEmpty ? preview : "Untitled CV",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text("Tap to view full CV"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCv(context, index),
                  ),
                  onTap: () {
                    // 🚀 Open ResultsScreen instead of dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultsScreen(resultText: cvs[index]),
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

import 'package:flutter/material.dart';
import 'results_screen.dart';
import '../cv_storage.dart';

class MyCvsScreen extends StatefulWidget {
  const MyCvsScreen({super.key});

  @override
  State<MyCvsScreen> createState() => _MyCvsScreenState();
}

class _MyCvsScreenState extends State<MyCvsScreen> {
  @override
  Widget build(BuildContext context) {
    final savedCvs = CvStorage.savedCvs;

    return Scaffold(
      appBar: AppBar(title: const Text("My CVs")),
      body:
          savedCvs.isEmpty
              ? const Center(
                child: Text("No CVs saved yet", style: TextStyle(fontSize: 16)),
              )
              : ListView.builder(
                itemCount: savedCvs.length,
                itemBuilder: (context, index) {
                  final preview = savedCvs[index];
                  return Dismissible(
                    key: ValueKey(preview.hashCode ^ index),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Delete CV?'),
                                  content: const Text(
                                    'This action cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          ) ??
                          false;
                    },
                    onDismissed: (_) async {
                      await CvStorage.removeAt(index);
                      if (mounted) setState(() {});
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text("CV ${index + 1}"),
                        subtitle: Text(
                          preview.substring(
                            0,
                            preview.length > 80 ? 80 : preview.length,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ResultsScreen(resultText: preview),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

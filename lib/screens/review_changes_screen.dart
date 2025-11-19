import 'package:flutter/material.dart';
import 'package:cv_helper_app/models/change_suggestion.dart';

class ReviewChangesScreen extends StatefulWidget {
  final List<ChangeSuggestion> suggestions;
  const ReviewChangesScreen({super.key, required this.suggestions});

  @override
  State<ReviewChangesScreen> createState() => _ReviewChangesScreenState();
}

class _ReviewChangesScreenState extends State<ReviewChangesScreen> {
  late List<ChangeSuggestion> items;

  @override
  void initState() {
    super.initState();
    items = widget.suggestions;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Changes'),
        actions: [
          TextButton(
            onPressed:
                () => setState(
                  () =>
                      items =
                          items.map((e) => e.copyWith(accepted: true)).toList(),
                ),
            child: const Text('Accept all'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = items[i];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.scope,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Switch(
                        value: s.accepted,
                        onChanged:
                            (v) => setState(
                              () => items[i] = s.copyWith(accepted: v),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Before', style: TextStyle(color: scheme.outline)),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.surfaceVariant.withOpacity(.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(s.before.isEmpty ? '—' : s.before),
                  ),
                  Text('After', style: TextStyle(color: scheme.outline)),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: scheme.primary.withOpacity(.25),
                      ),
                    ),
                    child: Text(s.after.isEmpty ? '—' : s.after),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(s.rationale)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final accepted = items.where((e) => e.accepted).toList();
                Navigator.pop(context, accepted);
              },
              child: const Text('Apply Accepted Changes'),
            ),
          ),
        ),
      ),
    );
  }
}

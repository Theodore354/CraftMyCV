import 'package:flutter/material.dart';
import 'package:cv_helper_app/models/index.dart';

class CvPreviewScreen extends StatelessWidget {
  final CvModel cv;
  const CvPreviewScreen({super.key, required this.cv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(cv.fullName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            if (cv.email.isNotEmpty) Text(cv.email),
            if (cv.phone.isNotEmpty) Text(cv.phone),
            if (cv.location.isNotEmpty) Text(cv.location),
            const SizedBox(height: 16),

            if (cv.workExperience.isNotEmpty) ...[
              Text(
                'Work Experience',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...cv.workExperience.map(
                (w) => ListTile(
                  title: Text('${w.jobTitle} — ${w.company}'),
                  subtitle: Text(
                    '${w.start} — ${w.end}'
                    '${(w.responsibilities == null || w.responsibilities!.isEmpty) ? '' : '\n${w.responsibilities}'}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (cv.education.isNotEmpty) ...[
              Text('Education', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...cv.education.map(
                (e) => ListTile(
                  title: Text('${e.degree} — ${e.institution}'),
                  subtitle: Text(
                    '${e.start} — ${e.end}'
                    '${(e.description == null || e.description!.isEmpty) ? '' : '\n${e.description}'}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (cv.skills.isNotEmpty) ...[
              Text('Skills', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: -8,
                children: cv.skills.map((s) => Chip(label: Text(s))).toList(),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
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

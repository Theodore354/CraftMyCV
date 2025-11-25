import 'package:flutter/material.dart';

import 'cv_form_screen.dart';
import 'cv_polisher_screen.dart';
import 'my_cvs_screen.dart';
import 'cover_letter_screen.dart';
import 'templates_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _go(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
    required Color accent,
    bool recommended = false,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _go(context, screen),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant.withOpacity(.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // icon bubble
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              "Recommended",
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: scheme.outline,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: scheme.outline.withOpacity(.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ===== Premium header =====
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary.withOpacity(.12),
                      scheme.secondary.withOpacity(.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CV Helper",
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: .2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Build, polish & export job-ready CVs",
                            style: textTheme.bodyMedium?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      tooltip: "My CVs",
                      onPressed: () => _go(context, const MyCvsScreen()),
                      icon: const Icon(Icons.folder_open_outlined),
                    ),
                    IconButton(
                      tooltip: "Templates",
                      onPressed: () => _go(context, const TemplatesScreen()),
                      icon: const Icon(Icons.dashboard_customize_outlined),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Hero card =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "https://img.freepik.com/free-vector/resume-concept-illustration_114360-5286.jpg",
                          height: 110,
                          width: 110,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 110,
                                width: 110,
                                alignment: Alignment.center,
                                color: scheme.surfaceContainerHighest
                                    .withOpacity(.6),
                                child: const Icon(Icons.image_not_supported),
                              ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Craft your perfect CV",
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Create a structured CV, polish an old one with AI, and export using clean templates.",
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 10),

                            SizedBox(
                              height: 40,
                              child: FilledButton.icon(
                                onPressed:
                                    () => _go(context, const CvFormScreen()),
                                icon: const Icon(Icons.add),
                                label: const Text("Start New CV"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== Actions list =====
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildActionTile(
                      context: context,
                      icon: Icons.description_outlined,
                      title: "Create New CV",
                      subtitle:
                          "Start from a guided form and save to the cloud.",
                      screen: const CvFormScreen(),
                      accent: scheme.primary,
                      recommended: true,
                    ),
                    _buildActionTile(
                      context: context,
                      icon: Icons.auto_fix_high_outlined,
                      title: "Polish Existing CV",
                      subtitle:
                          "Upload or paste your CV. AI suggests improvements.",
                      screen: const PolishCVScreen(),
                      accent: scheme.secondary,
                    ),
                    _buildActionTile(
                      context: context,
                      icon: Icons.folder_open_outlined,
                      title: "My CVs",
                      subtitle: "View, edit, duplicate, or delete saved CVs.",
                      screen: const MyCvsScreen(),
                      accent: Colors.teal,
                    ),
                    _buildActionTile(
                      context: context,
                      icon: Icons.markunread_mailbox_outlined,
                      title: "Cover Letter",
                      subtitle: "Generate a tailored cover letter with AI.",
                      screen: const CoverLetterScreen(),
                      accent: Colors.deepPurple,
                    ),
                    _buildActionTile(
                      context: context,
                      icon: Icons.dashboard_customize_outlined,
                      title: "Explore Templates",
                      subtitle: "Pick a style and export a designed CV.",
                      screen: const TemplatesScreen(),
                      accent: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

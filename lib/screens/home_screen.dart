import 'package:cv_helper_app/screens/cv_polisher_screen.dart';
import 'package:flutter/material.dart';
import 'cv_form_screen.dart';

import 'templates_screen.dart';
import 'my_cvs_screen.dart';
import 'cover_letter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
    Color? color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = color ?? scheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: iconColor.withOpacity(.10),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('CV Helper'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Hero image ---
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      "https://img.freepik.com/free-vector/resume-concept-illustration_114360-5286.jpg",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            height: 200,
                            alignment: Alignment.center,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                "Craft your perfect CV",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Create a new CV, polish your existing one, or explore templates with our tools.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 22),

              // Action cards
              _buildActionCard(
                context: context,
                icon: Icons.description_outlined,
                title: "Create New CV",
                subtitle: "Start from a guided form.",
                screen: const CvFormScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.upload_file_outlined,
                title: "Polish Existing CV",
                subtitle: "Upload or paste your CV to refine.",
                screen: const PolishCVScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.folder_open_outlined,
                title: "My CVs",
                subtitle: "View, edit, duplicate, or delete.",
                screen: const MyCvsScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.markunread_mailbox_outlined,
                title: "Cover Letter",
                subtitle: "Draft a tailored cover letter.",
                screen: const CoverLetterScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.dashboard_customize_outlined,
                title: "Explore Templates",
                subtitle: "Browse CV & cover letter templates.",
                screen: const TemplatesScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

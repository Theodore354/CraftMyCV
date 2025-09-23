import 'package:flutter/material.dart';
import 'cv_form_screen.dart';
import 'cv_polisher_screen.dart';
import 'templates_screen.dart';
import 'my_cvs_screen.dart';
import 'cover_letter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Quick Link Card ---
  Widget _quickLinkCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required Widget screen,
  }) {
    return Expanded(
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Action Card ---
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
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
                backgroundColor: Colors.blue.withOpacity(.10),
                child: Icon(icon, color: Colors.blue, size: 28),
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
      appBar: AppBar(
        title: const Text('CV Helper'),
        centerTitle: true,
        automaticallyImplyLeading: false, // no back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Hero Image ---
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

              const SizedBox(height: 18),

              // --- Quick Links ---
              Row(
                children: [
                  _quickLinkCard(
                    context: context,
                    icon: Icons.folder_copy,
                    color: Colors.blue,
                    label: "My CVs",
                    screen: const MyCvsScreen(),
                  ),
                  _quickLinkCard(
                    context: context,
                    icon: Icons.mark_email_read,
                    color: Colors.green,
                    label: "Cover Letter",
                    screen: const CoverLetterScreen(),
                  ),
                  _quickLinkCard(
                    context: context,
                    icon: Icons.dashboard_customize,
                    color: Colors.orange,
                    label: "Templates",
                    screen: const TemplatesScreen(),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // --- Action Cards ---
              _buildActionCard(
                context: context,
                icon: Icons.description,
                title: "Create New CV",
                subtitle: "Start from a guided form.",
                screen: const CvFormScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.upload_file,
                title: "Polish Existing CV",
                subtitle: "Upload or paste your CV to refine.",
                screen: const PolishCVScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.dashboard_customize,
                title: "Explore Templates",
                subtitle: "Browse CV & cover letter templates.",
                screen: const TemplatesScreen(),
              ),

              const SizedBox(height: 8),

              // --- Tip ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tip: You can save any result and find it later under My CVs. Export to PDF anytime.",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

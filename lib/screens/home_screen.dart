import 'package:flutter/material.dart';
import 'cv_form_screen.dart';
import 'cv_polisher_screen.dart';
import 'templates_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "https://img.freepik.com/free-vector/resume-concept-illustration_114360-5286.jpg",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 180,
                        alignment: Alignment.center,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Craft your perfect CV",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create a new CV, polish your existing one, or explore templates with our AI-powered tools.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              _buildActionCard(
                context: context,
                icon: Icons.description,
                title: "Create New CV",
                subtitle: "Start fresh and build your CV from scratch.",
                screen: const CvFormScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.upload_file,
                title: "Polish Existing CV",
                subtitle: "Upload your CV and let AI refine it.",
                screen: const PolishCVScreen(),
              ),
              _buildActionCard(
                context: context,
                icon: Icons.dashboard_customize,
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

// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cv_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    // Clear local cached CVs for privacy
    await CvStorage.clear();

    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();
    
    
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // Profile avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue.shade200,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),

              const SizedBox(height: 20),

              // User email
              Text(
                user?.email ?? "No email found",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 40),

              // Logout button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () => _logout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

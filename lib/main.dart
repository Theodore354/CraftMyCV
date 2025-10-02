import 'package:cv_helper_app/screens/login_screen.dart';
import 'package:cv_helper_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'cv_storage.dart';
import 'package:cv_helper_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load saved CVs
  await CvStorage.load();

  runApp(const CvHelperApp());
}

class CvHelperApp extends StatelessWidget {
  const CvHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Helper',
      debugShowCheckedModeBanner: false,

      
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, 

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // User logged in → show main screen
          return const MainScreen();
        } else {
          // User logged out → clear cached CVs for privacy
          CvStorage.clear();
          return const LoginScreen();
        }
      },
    );
  }
}

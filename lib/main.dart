import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cv_helper_app/screens/login_screen.dart';
import 'package:cv_helper_app/screens/main_screen.dart';
import 'package:cv_helper_app/firebase_options.dart';
import 'package:cv_helper_app/cv_storage.dart';
import 'package:cv_helper_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load cached CV drafts (for anonymous or last user)
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
        // Still loading user state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Auth error fallback
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error connecting to Firebase')),
          );
        }

        // Logged in → show main app
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          // Load per-user drafts
          CvStorage.load(uid: user.uid);
          return const MainScreen();
        }

        // Logged out → clear cached drafts & show login
        CvStorage.clear();
        return const LoginScreen();
      },
    );
  }
}

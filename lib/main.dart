import 'package:cv_helper_app/screens/results_screen.dart';
import 'package:flutter/material.dart';
import 'cv_storage.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load saved CVs before app starts
  await CvStorage.load();

  runApp(const CvHelperApp());
}

class CvHelperApp extends StatelessWidget {
  const CvHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV Helper',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

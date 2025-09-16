import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'cv_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CvStorage.init(); // load saved CVs before the app starts
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI CV Helper',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const MainScreen(),
    );
  }
}

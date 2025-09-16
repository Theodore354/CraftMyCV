import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_cvs_screen.dart';
import 'templates_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Screens for each tab
  final List<Widget> _screens = const [
    HomeScreen(),
    MyCvsScreen(), // ✅ No parameter anymore
    TemplatesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "My CVs"),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: "Templates",
          ),
        ],
      ),
    );
  }
}

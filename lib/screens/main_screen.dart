import 'package:flutter/material.dart';

import 'package:cv_helper_app/screens/home_screen.dart';
import 'package:cv_helper_app/screens/my_cvs_screen.dart';
import 'package:cv_helper_app/screens/templates_screen.dart';
import 'package:cv_helper_app/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final PageStorageBucket _bucket = PageStorageBucket();

  late final List<Widget> _pages = <Widget>[
    HomeScreen(key: const PageStorageKey('home')),
    const MyCvsScreen(key: PageStorageKey('my_cvs')),
    const TemplatesScreen(key: PageStorageKey('templates')),
    const ProfileScreen(key: PageStorageKey('profile')),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex =
        (widget.initialIndex >= 0 && widget.initialIndex < 4)
            ? widget.initialIndex
            : 0;
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.outline,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "My CVs"),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize),
            label: "Templates",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

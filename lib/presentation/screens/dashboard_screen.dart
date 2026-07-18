import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SubjectsScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFFFED65B) : const Color(0xFF111827);
    final inactiveColor = isDark ? const Color(0xFF484F58) : const Color(0xFFD1D5DB);
    final bgColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFF3F4F6);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        height: 64 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          children: [
            _tab(0, Icons.home_rounded, Icons.home_outlined, 'Home', activeColor, inactiveColor),
            _tab(1, Icons.menu_book_rounded, Icons.menu_book_outlined, 'Practice', activeColor, inactiveColor),
            _tab(2, Icons.person_rounded, Icons.person_outline_rounded, 'Profile', activeColor, inactiveColor),
            _tab(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings', activeColor, inactiveColor),
          ],
        ),
      ),
    );
  }

  Widget _tab(int i, IconData filled, IconData outlined, String label, Color active, Color inactive) {
    final sel = _currentIndex == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = i),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tiny dot indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sel ? 4 : 0,
              height: sel ? 4 : 0,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(shape: BoxShape.circle, color: active),
            ),
            Icon(sel ? filled : outlined, size: 22, color: sel ? active : inactive),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                color: sel ? active : inactive,
                letterSpacing: sel ? 0.3 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

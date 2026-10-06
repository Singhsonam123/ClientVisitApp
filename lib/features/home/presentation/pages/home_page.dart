import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../gallery/presentation/pages/gallery_page.dart';
import '../../../agenda/presentation/pages/agenda_page.dart';
import '../../../potluck/presentation/pages/potluck_page.dart';
import '../../../sweets/presentation/pages/sweets_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    AgendaPage(),
    PotluckPage(),
    SweetsPage(),
    GalleryPage(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'Agenda'),
    _NavItem(icon: Icons.restaurant_menu_rounded, label: 'Potluck'),
    _NavItem(icon: Icons.cake_rounded, label: 'Sweets'),
    _NavItem(icon: Icons.photo_library_rounded, label: 'Gallery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: _navItems
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
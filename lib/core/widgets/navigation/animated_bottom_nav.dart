import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const AnimatedBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SalomonBottomBar(
          currentIndex: widget.currentIndex,
          onTap: widget.onTap,
          items: widget.items.map((item) {
            return SalomonBottomBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              title: Text(item.label),
              selectedColor: item.color ?? theme.colorScheme.primary,
              unselectedColor: theme.colorScheme.onSurfaceVariant,
            );
          }).toList(),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 300),
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurfaceVariant,
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;

  BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
  });
}

// Factory for creating standard nav items
class NavItems {
  static BottomNavItem home({Color? color}) => BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        color: color,
      );

  static BottomNavItem explore({Color? color}) => BottomNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Explore',
        color: color,
      );

  static BottomNavItem events({Color? color}) => BottomNavItem(
        icon: Icons.event_outlined,
        activeIcon: Icons.event,
        label: 'Events',
        color: color,
      );

  static BottomNavItem community({Color? color}) => BottomNavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Community',
        color: color,
      );

  static BottomNavItem profile({Color? color}) => BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        color: color,
      );

  static BottomNavItem upload({Color? color}) => BottomNavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'Upload',
        color: color,
      );

  static BottomNavItem notifications({Color? color}) => BottomNavItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Alerts',
        color: color,
      );

  static BottomNavItem admin({Color? color}) => BottomNavItem(
        icon: Icons.admin_panel_settings_outlined,
        activeIcon: Icons.admin_panel_settings,
        label: 'Admin',
        color: color,
      );
}
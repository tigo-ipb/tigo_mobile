import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral300, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _NavBarItem(
              label: 'Home',
              icon: TablerIcons.smartHome,
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              label: 'Explore',
              icon: TablerIcons.compass,
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              label: 'Ticket',
              icon: TablerIcons.ticket,
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _NavBarItem(
              label: 'Profile',
              icon: TablerIcons.userCircle,
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: isActive ? AppColors.sky500 : AppColors.neutral400,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.medium(
              12,
              isActive ? AppColors.sky500 : AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

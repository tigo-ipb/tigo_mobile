import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class FilterTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTag({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.sky500 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.sky500 : AppColors.neutral100,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.neutral400,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.medium(
                14,
                isSelected ? Colors.white : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

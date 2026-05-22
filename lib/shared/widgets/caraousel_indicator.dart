import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class CarouselIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final Color? activeColor;
  final Color? inactiveColor;

  const CarouselIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? AppColors.sky500)
                : (inactiveColor ?? AppColors.neutral200),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

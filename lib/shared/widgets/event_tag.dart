import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

class EventTag extends StatelessWidget {
  final String category;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;

  const EventTag({
    super.key,
    required this.category,
    this.fontSize = 10.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = _getNormalizedCategory(category);
    if (displayLabel.isEmpty) return const SizedBox.shrink();

    final themeColor = color ?? AppColors.sky500;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(color: themeColor, width: 1.2),
      ),
      child: Text(
        displayLabel,
        style: AppTextStyles.medium(fontSize, themeColor),
      ),
    );
  }

  String _getNormalizedCategory(String cat) {
    final clean = cat.trim().toLowerCase();
    if (clean == 'olahraga') {
      return 'Olahraga';
    } else if (clean == 'edukasi') {
      return 'Edukasi';
    } else if (clean == 'seni & budaya' ||
        clean == 'seni' ||
        clean == 'budaya' ||
        clean == 'seni dan budaya') {
      return 'Seni & Budaya';
    } else if (clean == 'hiburan & festival' ||
        clean == 'hiburan' ||
        clean == 'festival' ||
        clean == 'hiburan dan festival') {
      return 'Hiburan & Festival';
    }

    if (cat.isEmpty) return '';

    // Capitalize first letter of each word
    return cat
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}

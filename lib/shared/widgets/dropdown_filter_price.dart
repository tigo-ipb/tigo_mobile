import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';

enum PriceSortOption {
  harga,
  termahal,
  termurah;

  String get label {
    switch (this) {
      case PriceSortOption.harga:
        return 'Harga';
      case PriceSortOption.termahal:
        return 'Termahal';
      case PriceSortOption.termurah:
        return 'Termurah';
    }
  }
}

class DropdownFilterPrice extends StatelessWidget {
  final PriceSortOption selectedOption;
  final ValueChanged<PriceSortOption> onChanged;

  const DropdownFilterPrice({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<PriceSortOption>(
          initialValue: selectedOption,
          onSelected: onChanged,
          offset: const Offset(0, 48),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.07),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.neutral300),
          ),
          color: Colors.white,
          itemBuilder: (context) {
            return PriceSortOption.values
                .where((option) => option != PriceSortOption.harga)
                .map((option) {
                  final isSelected = selectedOption == option;
                  return PopupMenuItem<PriceSortOption>(
                    value: option,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option.label,
                          style: isSelected
                              ? AppTextStyles.medium(12, AppColors.sky500)
                              : AppTextStyles.regular(12, AppColors.neutral500),
                        ),
                        if (isSelected)
                          const Icon(
                            TablerIcons.check,
                            size: 16,
                            color: AppColors.sky500,
                          ),
                      ],
                    ),
                  );
                })
                .toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutral300, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedOption.label,
                  style: AppTextStyles.medium(12, AppColors.neutral950),
                ),
                Icon(
                  TablerIcons.selector,
                  size: 16,
                  color: selectedOption == PriceSortOption.harga
                      ? AppColors.neutral400
                      : AppColors.neutral950,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

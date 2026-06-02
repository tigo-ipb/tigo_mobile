import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';

enum DateSortOption {
  tanggal,
  terlama,
  terbaru;

  String get label {
    switch (this) {
      case DateSortOption.tanggal:
        return 'Tanggal';
      case DateSortOption.terlama:
        return 'Terlama';
      case DateSortOption.terbaru:
        return 'Terbaru';
    }
  }
}

class DropdownFilterDate extends StatelessWidget {
  final DateSortOption selectedOption;
  final ValueChanged<DateSortOption> onChanged;

  const DropdownFilterDate({
    super.key,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          child: PopupMenuButton<DateSortOption>(
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
              return DateSortOption.values.map((option) {
                final isSelected = selectedOption == option;
                return PopupMenuItem<DateSortOption>(
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
              }).toList();
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
                    color: selectedOption == DateSortOption.tanggal
                        ? AppColors.neutral400
                        : AppColors.neutral950,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

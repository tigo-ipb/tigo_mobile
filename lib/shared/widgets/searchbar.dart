import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/constants/app_icons.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;
  final bool isFilterActive;
  final String hintText;
  final bool showFilter;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
    this.isFilterActive = false,
    this.hintText = 'Cari event',
    this.showFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.regular(16, AppColors.neutral950),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.regular(16, AppColors.neutral300),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(AppIcons.search, color: AppColors.neutral300, size: 24),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 52,
          minHeight: 24,
        ),
        suffixIcon: showFilter
            ? InkWell(
                onTap: onFilterTap,
                borderRadius: BorderRadius.circular(100),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, left: 12),
                  child: Icon(
                    AppIcons.filter,
                    color:
                        isFilterActive ? AppColors.sky500 : AppColors.neutral300,
                    size: 24,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 52,
          minHeight: 24,
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: AppColors.neutral300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: AppColors.sky500, width: 1),
        ),
      ),
    );
  }
}

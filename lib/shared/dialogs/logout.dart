import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../widgets/custom_button.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Large Logout Icon
              Icon(AppIcons.logout, size: 64, color: AppColors.red500),
              const SizedBox(height: 16),

              // Title
              Text(
                'Log Out?',
                style: AppTextStyles.semiBold(24, AppColors.neutral950),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Anda yakin ingin keluar dari aplikasi?',
                style: AppTextStyles.regular(14, AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Log Out Action Button
              CustomButton(
                text: 'Log Out',
                onPressed: () {
                  Navigator.pop(context, true);
                },
                isDestroy: true,
                size: CustomButtonSize.medium,
                width: double.infinity,
              ),
              const SizedBox(height: 8),

              // Batal Action Button
              CustomButton(
                text: 'Batal',
                onPressed: () {
                  Navigator.pop(context, false);
                },
                isOutlined: true,
                backgroundColor: AppColors.neutral300,
                textColor: AppColors.neutral950,
                size: CustomButtonSize.medium,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

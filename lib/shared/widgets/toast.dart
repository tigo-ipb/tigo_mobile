import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';

enum ToastType { success, error }

class ToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;

  const ToastWidget({
    super.key,
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == ToastType.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutral200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSuccess ? AppColors.green100 : AppColors.red100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isSuccess ? TablerIcons.check : TablerIcons.circleX,
              color: isSuccess ? AppColors.green500 : AppColors.red500,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          // Title & Description
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bold(16, AppColors.neutral950),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.regular(14, AppColors.neutral600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppToast {
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    show(context, title: title, message: message, type: ToastType.success);
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    show(context, title: title, message: message, type: ToastType.error);
  }

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required ToastType type,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        duration: const Duration(seconds: 4),
        content: ToastWidget(title: title, message: message, type: type),
      ),
    );
  }
}

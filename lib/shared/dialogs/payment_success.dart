import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/constants/app_icons.dart';
import '../widgets/custom_button.dart';

class PaymentSuccessDialog extends StatelessWidget {
  final String eventName;
  final VoidCallback onViewTicket;
  final VoidCallback onBackToHome;

  const PaymentSuccessDialog({
    super.key,
    required this.eventName,
    required this.onViewTicket,
    required this.onBackToHome,
  });

  static Future<void> show(
    BuildContext context, {
    required String eventName,
    required VoidCallback onViewTicket,
    required VoidCallback onBackToHome,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PaymentSuccessDialog(
          eventName: eventName,
          onViewTicket: onViewTicket,
          onBackToHome: onBackToHome,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final double blurValue = animation.value * 5.0;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Squircle Check Circle Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.sky500, width: 4),
              ),
              child: Icon(AppIcons.check, size: 40, color: AppColors.sky500),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Pembayaran Berhasil!',
              style: AppTextStyles.semiBold(20, AppColors.neutral950),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Kamu telah berhasil membeli tiket untuk $eventName. Selamat menikmati event!',
              style: AppTextStyles.regular(14, AppColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Lihat E-Tiket Action Button
            CustomButton(
              text: 'Lihat E-Tiket',
              onPressed: onViewTicket,
              size: CustomButtonSize.large,
              width: double.infinity,
            ),
            const SizedBox(height: 12),

            // Kembali ke beranda Action Button
            CustomButton(
              text: 'Kembali ke beranda',
              onPressed: onBackToHome,
              isOutlined: true,
              backgroundColor: AppColors.neutral300,
              textColor: AppColors.neutral950,
              size: CustomButtonSize.large,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}

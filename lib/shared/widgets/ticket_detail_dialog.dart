import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';

class TicketDetailDialog extends StatelessWidget {
  final String ticketName;
  final String description;

  const TicketDetailDialog({
    super.key,
    required this.ticketName,
    required this.description,
  });

  static Future<void> show(
    BuildContext context, {
    required String ticketName,
    required String description,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TicketDetailDialog(
          ticketName: ticketName,
          description: description,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    ticketName,
                    style: AppTextStyles.medium(18, AppColors.sky500),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    TablerIcons.x,
                    color: AppColors.neutral950,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description text
            Text(
              description.isNotEmpty
                  ? description
                  : 'Tidak ada deskripsi tambahan untuk tiket ini.',
              style: AppTextStyles.regular(
                14,
                AppColors.neutral700,
              ).copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

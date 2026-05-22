import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';

enum PaymentStatus {
  paid,
  pending,
  cancelled,
}

class PaymentStatusTag extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusTag({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case PaymentStatus.paid:
        color = AppColors.green500;
        label = 'Dibayar';
        break;
      case PaymentStatus.pending:
        color = AppColors.yellow500;
        label = 'Menunggu';
        break;
      case PaymentStatus.cancelled:
        color = AppColors.red500;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: AppTextStyles.medium(12, color),
      ),
    );
  }
}

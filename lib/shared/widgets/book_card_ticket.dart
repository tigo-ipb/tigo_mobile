import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';
import 'ticket_detail_dialog.dart';

class BookCardTicket extends StatelessWidget {
  final String name;
  final int price;
  final int quantity;
  final int availableStock;
  final String description;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const BookCardTicket({
    super.key,
    required this.name,
    required this.price,
    required this.quantity,
    required this.availableStock,
    required this.description,
    required this.onIncrement,
    required this.onDecrement,
  });

  String _formatPrice(int price) {
    if (price <= 0) return 'Free';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp.$formatted';
  }

  void _showDetailDialog(BuildContext context) {
    TicketDetailDialog.show(
      context,
      ticketName: name,
      description: description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSoldOut = availableStock <= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.sky50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: quantity > 0 ? AppColors.sky500 : AppColors.sky200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Ticket Name & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.medium(
                    18,
                    isSoldOut ? AppColors.neutral400 : AppColors.neutral950,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatPrice(price),
                style: AppTextStyles.medium(
                  18,
                  isSoldOut ? AppColors.neutral400 : AppColors.neutral950,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Middle Row: Qty Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Minus Button
              _buildQtyButton(
                icon: TablerIcons.minus,
                onTap: (!isSoldOut && quantity > 0) ? onDecrement : null,
                isActive: !isSoldOut && quantity > 0,
              ),

              // Quantity
              Text(
                isSoldOut ? '0' : '$quantity',
                style: AppTextStyles.semiBold(
                  18,
                  isSoldOut ? AppColors.neutral400 : AppColors.neutral950,
                ),
              ),

              // Plus Button
              _buildQtyButton(
                icon: TablerIcons.plus,
                onTap: (!isSoldOut && quantity < availableStock)
                    ? onIncrement
                    : null,
                isActive: !isSoldOut && quantity < availableStock,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottom Row: Info Link
          GestureDetector(
            onTap: () => _showDetailDialog(context),
            child: Text(
              'Lihat detail tiket',
              style: AppTextStyles.medium(14, AppColors.sky500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? AppColors.sky500 : AppColors.sky200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

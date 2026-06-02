import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import '../../core/constants/app_icons.dart';
import 'custom_button.dart';

class TicketCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String organizerName;
  final String? organizerLogoUrl;
  final String date;
  final String time;
  final String location;
  final bool isHistory;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.organizerName,
    this.organizerLogoUrl,
    required this.date,
    required this.time,
    required this.location,
    this.isHistory = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Event Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: AppColors.neutral100,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.neutral300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.medium(14, AppColors.neutral950),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Organizer
                    Row(
                      children: [
                        if (organizerLogoUrl != null)
                          ClipOval(
                            child: Image.network(
                              organizerLogoUrl!,
                              width: 16,
                              height: 16,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Icon(
                            AppIcons.profile,
                            size: 16,
                            color: AppColors.sky500,
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            organizerName,
                            style: AppTextStyles.regular(
                              12,
                              AppColors.neutral950,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date & Time
                    Row(
                      children: [
                        Icon(AppIcons.clock, size: 16, color: AppColors.sky500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            time.isNotEmpty ? '$date • $time' : date,
                            style: AppTextStyles.regular(
                              12,
                              AppColors.neutral950,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(
                          AppIcons.location,
                          size: 16,
                          color: AppColors.sky500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTextStyles.regular(
                              12,
                              AppColors.neutral950,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Divider
          const Divider(color: AppColors.neutral200, height: 1),
          const SizedBox(height: 12),
          // Button
          CustomButton(
            text: isHistory ? 'Lihat Detail Tiket' : 'Lihat E-Tiket',
            onPressed: onTap,
            size: CustomButtonSize.small,
            isOutlined: isHistory,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

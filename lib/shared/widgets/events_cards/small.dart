import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../event_tag.dart';

class EventCardSmall extends StatelessWidget {
  final String? title;
  final String? organizerName;
  final String? date;
  final String? time;
  final String? location;
  final String? price;
  final String? imageUrl;
  final String? organizerImageUrl;
  final String? category;

  const EventCardSmall({
    super.key,
    this.title,
    this.organizerName,
    this.date,
    this.time,
    this.location,
    this.price,
    this.imageUrl,
    this.organizerImageUrl,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 100,
              height: 100,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.neutral100,
                      child: Icon(
                        AppIcons.calendar,
                        size: 24,
                        color: AppColors.neutral300,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Right: Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (category != null && category!.isNotEmpty) ...[
                  EventTag(
                    category: category!,
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                // Title
                Text(
                  title ?? 'Title',
                  style: AppTextStyles.medium(14, AppColors.neutral950),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Organizer
                Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: AppColors.neutral200,
                      backgroundImage: organizerImageUrl != null
                          ? NetworkImage(organizerImageUrl!)
                          : null,
                      child: organizerImageUrl == null
                          ? Icon(
                              AppIcons.profile,
                              size: 10,
                              color: AppColors.neutral400,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        organizerName ?? 'Picture profile',
                        style: AppTextStyles.regular(12, AppColors.neutral950),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Date & Time
                Row(
                  children: [
                    Icon(AppIcons.clock, size: 16, color: AppColors.sky500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${date ?? 'Sen, 1 Agustus'} • ${time ?? '08.00 - 13.00'}',
                        style: AppTextStyles.regular(12, AppColors.neutral950),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    Icon(AppIcons.location, size: 16, color: AppColors.sky500),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location ?? 'Location',
                        style: AppTextStyles.regular(12, AppColors.neutral950),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

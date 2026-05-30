import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../event_tag.dart';

class EventCardMid extends StatelessWidget {
  final String? title;
  final String? organizerName;
  final String? date;
  final String? time;
  final String? location;
  final String? price;
  final String? imageUrl;
  final String? organizerImageUrl;
  final String? category;

  const EventCardMid({
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
      width: 248, // Approximate width for "mid" card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Image
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
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
                  if (category != null && category!.isNotEmpty)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: EventTag(
                        category: category!,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title ?? 'Title',
                  style: AppTextStyles.medium(14, AppColors.neutral950),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

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
                const SizedBox(height: 10),

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
                const SizedBox(height: 10),

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

                const SizedBox(height: 16),

                // Price Section
                Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Mulai dari',
                        style: AppTextStyles.regular(10, AppColors.neutral950),
                      ),
                      Text(
                        price ?? 'Free',
                        style: AppTextStyles.medium(14, AppColors.neutral900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

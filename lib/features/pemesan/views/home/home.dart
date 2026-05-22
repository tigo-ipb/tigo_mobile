import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../shared/widgets/events_cards/mid.dart';
import '../../../../shared/widgets/events_cards/small.dart';
import '../../../../shared/widgets/filter_tag.dart';
import '../../../../shared/widgets/caraousel.dart';
import '../../../../shared/widgets/searchbar.dart';
import '../../../../core/constants/app_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Search Bar (Without Filter)
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: CustomSearchBar(showFilter: false),
              ),

              // 1. Carousel Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomCarousel(
                  images: [
                    'https://picsum.photos/id/1/800/400',
                    'https://picsum.photos/id/2/800/400',
                    'https://picsum.photos/id/3/800/400',
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Filter Tag (Categories)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    FilterTag(
                      label: 'Semua',
                      icon: TablerIcons.squareRoundedCheck,
                      isSelected: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    FilterTag(
                      label: 'Edukasi',
                      icon: TablerIcons.book,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    FilterTag(
                      label: 'Hiburan & Festival',
                      icon: TablerIcons.buildingCarousel,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    FilterTag(
                      label: 'Seni & Budaya',
                      icon: TablerIcons.brush,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    FilterTag(
                      label: 'Olahraga',
                      icon: TablerIcons.ballBasketball,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. Featured Events
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilihan untuk kamu',
                  style: AppTextStyles.medium(20, AppColors.neutral950),
                ),
              ),
              const SizedBox(height: 16),
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    EventCardMid(
                      title: 'Workshop Flutter Advanced',
                      organizerName: 'Google Developers',
                      location: 'Jakarta, Indonesia',
                      price: 'Rp 150.000',
                    ),
                    SizedBox(width: 16),
                    EventCardMid(
                      title: 'Music Festival 2026',
                      organizerName: 'Tigo Production',
                      location: 'Bandung, Indonesia',
                      price: 'Free',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. Popular Events
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Event lainnya',
                  style: AppTextStyles.medium(20, AppColors.neutral950),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    EventCardSmall(
                      title: 'Flutter Meetup Jakarta',
                      organizerName: 'Flutter Indonesia',
                      location: 'Jakarta Selatan',
                    ),
                    SizedBox(height: 12),
                    EventCardSmall(
                      title: 'UI/UX Design Talk',
                      organizerName: 'Design Community',
                      location: 'Online via Zoom',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

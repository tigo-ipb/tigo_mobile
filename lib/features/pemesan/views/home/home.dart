import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../shared/widgets/events_cards/mid.dart';
import '../../../../shared/widgets/events_cards/small.dart';
import '../../../../shared/widgets/filter_tag.dart';
import '../../../../shared/widgets/caraousel.dart';
import '../../../../shared/widgets/searchbar.dart';
import '../../../../shared/widgets/home_shimmer.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../blocs/home_bloc.dart';
import '../../models/event_model.dart';
import '../explore/event_details.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeBloc _homeBloc;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc();
    _homeBloc.fetchHome();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });
    if (categoryName == 'Semua') {
      _homeBloc.fetchHome();
    } else {
      _homeBloc.fetchHome(category: categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_selectedCategory == 'Semua') {
              await _homeBloc.fetchHome();
            } else {
              await _homeBloc.fetchHome(category: _selectedCategory);
            }
          },
          color: AppColors.sky500,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                ListenableBuilder(
                  listenable: _homeBloc,
                  builder: (context, _) {
                    if (_homeBloc.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SkeletonPlaceholder(
                          width: double.infinity,
                          height: 150,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      );
                    }

                    final carouselImages = _homeBloc.featuredEvents.isNotEmpty
                        ? _homeBloc.featuredEvents
                              .take(3)
                              .map((e) => AppConstants.resolveImageUrl(e.image))
                              .toList()
                        : [
                            'https://picsum.photos/id/1/800/400',
                            'https://picsum.photos/id/2/800/400',
                            'https://picsum.photos/id/3/800/400',
                          ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomCarousel(images: carouselImages),
                    );
                  },
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
                        isSelected: _selectedCategory == 'Semua',
                        onTap: () => _onCategorySelected('Semua'),
                      ),
                      const SizedBox(width: 12),
                      FilterTag(
                        label: 'Edukasi',
                        icon: TablerIcons.book,
                        isSelected: _selectedCategory == 'Edukasi',
                        onTap: () => _onCategorySelected('Edukasi'),
                      ),
                      const SizedBox(width: 12),
                      FilterTag(
                        label: 'Hiburan & Festival',
                        icon: TablerIcons.buildingCarousel,
                        isSelected: _selectedCategory == 'Hiburan & Festival',
                        onTap: () => _onCategorySelected('Hiburan & Festival'),
                      ),
                      const SizedBox(width: 12),
                      FilterTag(
                        label: 'Seni & Budaya',
                        icon: TablerIcons.brush,
                        isSelected: _selectedCategory == 'Seni & Budaya',
                        onTap: () => _onCategorySelected('Seni & Budaya'),
                      ),
                      const SizedBox(width: 12),
                      FilterTag(
                        label: 'Olahraga',
                        icon: TablerIcons.ballBasketball,
                        isSelected: _selectedCategory == 'Olahraga',
                        onTap: () => _onCategorySelected('Olahraga'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Listenable Content for Events
                ListenableBuilder(
                  listenable: _homeBloc,
                  builder: (context, _) {
                    if (_homeBloc.isLoading) {
                      return const HomeShimmer();
                    }

                    if (_homeBloc.status == HomeStatus.error) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 32,
                          ),
                          child: Column(
                            children: [
                              Text(
                                _homeBloc.errorMessage ?? 'Gagal memuat data.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.regular(
                                  14,
                                  AppColors.neutral500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedCategory == 'Semua') {
                                    _homeBloc.fetchHome();
                                  } else {
                                    _homeBloc.fetchHome(
                                      category: _selectedCategory,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sky500,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    List<EventModel> featured = List.from(
                      _homeBloc.featuredEvents,
                    );
                    List<EventModel> others = List.from(_homeBloc.otherEvents);

                    if (featured.length > 6) {
                      final surplus = featured.sublist(6);
                      featured = featured.sublist(0, 6);
                      others.insertAll(0, surplus);
                    } else if (others.isEmpty && featured.length > 2) {
                      others = featured.sublist(2);
                      featured = featured.sublist(0, 2);
                    }

                    if (featured.isEmpty && others.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64),
                          child: Text(
                            'Tidak ada event tersedia.',
                            style: AppTextStyles.regular(
                              14,
                              AppColors.neutral500,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3. Featured Events
                        if (featured.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Pilihan untuk kamu',
                              style: AppTextStyles.medium(
                                20,
                                AppColors.neutral950,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: featured.map((event) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventDetailsView(event: event),
                                        ),
                                      );
                                    },
                                    child: EventCardMid(
                                      title: event.name,
                                      organizerName: event.organizerName,
                                      date: event.schedule,
                                      location: event.venue,
                                      price: event.formattedPrice,
                                      imageUrl: AppConstants.resolveImageUrl(
                                        event.image,
                                      ),
                                      organizerImageUrl:
                                          AppConstants.resolveImageUrl(
                                            event.organizerPhoto,
                                          ),
                                      category: event.category,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // 4. Popular/Other Events
                        if (others.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Event lainnya',
                              style: AppTextStyles.medium(
                                20,
                                AppColors.neutral950,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: others.map((event) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EventDetailsView(event: event),
                                        ),
                                      );
                                    },
                                    child: EventCardSmall(
                                      title: event.name,
                                      organizerName: event.organizerName,
                                      date: event.schedule,
                                      location: event.venue,
                                      price: event.formattedPrice,
                                      imageUrl: AppConstants.resolveImageUrl(
                                        event.image,
                                      ),
                                      organizerImageUrl:
                                          AppConstants.resolveImageUrl(
                                            event.organizerPhoto,
                                          ),
                                      category: event.category,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

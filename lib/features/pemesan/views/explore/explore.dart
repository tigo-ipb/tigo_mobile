import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:tigo_mobile/features/pemesan/views/explore/event_details.dart';
import 'package:tigo_mobile/features/pemesan/views/explore/no_result_filter.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/events_cards/large.dart';
import '../../../../shared/widgets/searchbar.dart';
import '../../../../shared/dialogs/filter_sheet.dart';
import '../../../../shared/widgets/filter_tag.dart';
import '../../../../shared/widgets/dropdown_filter_price.dart';
import '../../../../shared/widgets/dropdown_filter_date.dart';
import '../../blocs/explore_bloc.dart';
import '../../models/event_model.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  late final ExploreBloc _exploreBloc;
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  FilterData? currentFilters;
  PriceSortOption priceSort = PriceSortOption.harga;
  DateSortOption dateSort = DateSortOption.tanggal;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _exploreBloc = ExploreBloc();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _applyAllFilters();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _exploreBloc.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _exploreBloc.loadNextPage();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyAllFilters();
    });
  }

  void _applyAllFilters() {
    final filters = currentFilters;

    String? startStr;
    String? endStr;
    if (filters?.dateRange != null) {
      startStr = _formatDate(filters!.dateRange!.start);
      endStr = _formatDate(filters.dateRange!.end);
    }

    String? categoryStr;
    if (filters?.categories.isNotEmpty == true) {
      categoryStr = filters!.categories.first;
    }

    String? formatStr;
    if (filters?.isOnline == true) {
      formatStr = 'online';
    } else if (filters?.isOffline == true) {
      formatStr = 'offline';
    }

    _exploreBloc.fetchExplore(
      name: _searchController.text,
      category: categoryStr,
      address: filters?.location,
      startDate: startStr,
      endDate: endStr,
      priceMin: filters?.minPrice?.toInt(),
      priceMax: filters?.maxPrice?.toInt(),
      format: formatStr,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _toggleCategoryFilter(String category) {
    setState(() {
      final filters = currentFilters ?? FilterData();
      final newCategories = List<String>.from(filters.categories);
      if (newCategories.contains(category)) {
        newCategories.remove(category);
      } else {
        newCategories.clear(); // Kita pakai single category untuk API
        newCategories.add(category);
      }
      currentFilters = FilterData(
        categories: newCategories,
        dateRange: filters.dateRange,
        location: filters.location,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        isOffline: filters.isOffline,
        isOnline: filters.isOnline,
      );
    });
    _applyAllFilters();
  }

  DateTime? _parseScheduleDate(String schedule) {
    final parsed = DateTime.tryParse(schedule);
    if (parsed != null) return parsed;

    try {
      final clean = schedule.replaceAll(',', ' ').toLowerCase().trim();
      final parts = clean.split(RegExp(r'\s+'));

      int? day;
      int? month;
      int? year;

      const months = {
        'jan': 1,
        'january': 1,
        'feb': 2,
        'february': 2,
        'mar': 3,
        'march': 3,
        'apr': 4,
        'april': 4,
        'may': 5,
        'jun': 6,
        'june': 6,
        'jul': 7,
        'july': 7,
        'aug': 8,
        'august': 8,
        'sep': 9,
        'september': 9,
        'oct': 10,
        'october': 10,
        'nov': 11,
        'november': 11,
        'dec': 12,
        'december': 12,
      };

      for (final part in parts) {
        if (months.containsKey(part)) {
          month = months[part];
        } else {
          final val = int.tryParse(part);
          if (val != null) {
            if (part.length == 4) {
              year = val;
            } else if (val >= 1 && val <= 31) {
              day = val;
            }
          }
        }
      }

      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    } catch (_) {
      // Ignore and fallback
    }
    return null;
  }

  List<EventModel> _getSortedEvents(List<EventModel> events) {
    final list = List<EventModel>.from(events);

    // Urutkan berdasarkan harga
    if (priceSort == PriceSortOption.termurah) {
      list.sort((a, b) => a.lowestPrice.compareTo(b.lowestPrice));
    } else if (priceSort == PriceSortOption.termahal) {
      list.sort((a, b) => b.lowestPrice.compareTo(a.lowestPrice));
    }

    // Urutkan berdasarkan tanggal
    if (dateSort == DateSortOption.terbaru ||
        dateSort == DateSortOption.terlama) {
      list.sort((a, b) {
        final dateA = _parseScheduleDate(a.schedule) ?? DateTime(1970);
        final dateB = _parseScheduleDate(b.schedule) ?? DateTime(1970);
        return dateSort == DateSortOption.terlama
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isFilterActive = currentFilters != null && currentFilters!.isActive;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                isFilterActive: isFilterActive,
                onFilterTap: () async {
                  final result = await showModalBottomSheet<FilterData>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        FilterSheet(initialFilters: currentFilters),
                  );

                  if (result != null) {
                    setState(() {
                      currentFilters = result;
                    });
                    _applyAllFilters();
                  }
                },
              ),
            ),

            // Category Tags (Horizontally Scrollable)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  FilterTag(
                    label: 'Edukasi',
                    icon: TablerIcons.book,
                    isSelected:
                        currentFilters?.categories.contains('Edukasi') ?? false,
                    onTap: () => _toggleCategoryFilter('Edukasi'),
                  ),
                  const SizedBox(width: 8),
                  FilterTag(
                    label: 'Hiburan & Festival',
                    icon: TablerIcons.ticket,
                    isSelected:
                        currentFilters?.categories.contains(
                          'Hiburan & Festival',
                        ) ??
                        false,
                    onTap: () => _toggleCategoryFilter('Hiburan & Festival'),
                  ),
                  const SizedBox(width: 8),
                  FilterTag(
                    label: 'Seni & Budaya',
                    icon: TablerIcons.palette,
                    isSelected:
                        currentFilters?.categories.contains('Seni & Budaya') ??
                        false,
                    onTap: () => _toggleCategoryFilter('Seni & Budaya'),
                  ),
                  const SizedBox(width: 8),
                  FilterTag(
                    label: 'Olahraga',
                    icon: TablerIcons.ballBasketball,
                    isSelected:
                        currentFilters?.categories.contains('Olahraga') ??
                        false,
                    onTap: () => _toggleCategoryFilter('Olahraga'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dropdown Sort Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownFilterPrice(
                      selectedOption: priceSort,
                      onChanged: (val) {
                        setState(() {
                          priceSort = val;
                          if (val != PriceSortOption.harga) {
                            dateSort = DateSortOption.tanggal;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownFilterDate(
                      selectedOption: dateSort,
                      onChanged: (val) {
                        setState(() {
                          dateSort = val;
                          if (val != DateSortOption.tanggal) {
                            priceSort = PriceSortOption.harga;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.neutral300, height: 1, thickness: 1),
            const SizedBox(height: 16),

            Expanded(
              child: ListenableBuilder(
                listenable: _exploreBloc,
                builder: (context, _) {
                  if (_exploreBloc.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.sky500),
                    );
                  }

                  if (_exploreBloc.status == ExploreStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _exploreBloc.errorMessage ?? 'Gagal memuat data.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.regular(
                                14,
                                AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _applyAllFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.sky500,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final events = _getSortedEvents(_exploreBloc.events);

                  if (events.isEmpty) {
                    return NoResultFilter(
                      isSearchMode: _searchController.text.trim().isNotEmpty,
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount:
                        events.length + (_exploreBloc.isLoadingMore ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      if (index == events.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(
                              color: AppColors.sky500,
                            ),
                          ),
                        );
                      }

                      final event = events[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailsView(eventId: event.id),
                            ),
                          );
                        },
                        child: EventCardLarge(
                          title: event.name,
                          organizerName: event.organizerName,
                          date: event.schedule,
                          location: event.venue,
                          price: event.formattedPrice,
                          imageUrl: AppConstants.resolveImageUrl(event.image),
                          organizerImageUrl: AppConstants.resolveImageUrl(
                            event.organizerPhoto,
                          ),
                          category: event.category,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

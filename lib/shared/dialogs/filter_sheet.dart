import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../core/constants/app_theme.dart';
import '../../core/constants/app_icons.dart';
import 'date_range_modal.dart';
import '../widgets/filter_tag.dart';
import '../widgets/input.dart';
import '../widgets/custom_button.dart';

class FilterData {
  final List<String> categories;
  final DateTimeRange? dateRange;
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final bool isOffline;
  final bool isOnline;

  FilterData({
    this.categories = const [],
    this.dateRange,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.isOffline = false,
    this.isOnline = false,
  });

  bool get isActive =>
      categories.isNotEmpty ||
      dateRange != null ||
      (location != null && location!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      isOffline ||
      isOnline;
}

class FilterSheet extends StatefulWidget {
  final FilterData? initialFilters;

  const FilterSheet({super.key, this.initialFilters});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  List<String> _selectedCategories = [];
  DateTimeRange? _selectedDateRange;
  late final TextEditingController _dateController;
  late final TextEditingController _locationController;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  bool _isOfflineSelected = false;
  bool _isOnlineSelected = false;

  @override
  void initState() {
    super.initState();
    // Load initial filters if any
    final init = widget.initialFilters;
    _selectedCategories = List<String>.from(init?.categories ?? []);
    _selectedDateRange = init?.dateRange;
    _isOfflineSelected = init?.isOffline ?? false;
    _isOnlineSelected = init?.isOnline ?? false;

    _dateController = TextEditingController(
      text: _selectedDateRange != null
          ? (_selectedDateRange!.start.day == _selectedDateRange!.end.day &&
                    _selectedDateRange!.start.month ==
                        _selectedDateRange!.end.month &&
                    _selectedDateRange!.start.year ==
                        _selectedDateRange!.end.year
                ? "${_selectedDateRange!.start.day.toString().padLeft(2, '0')}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.year}"
                : "${_selectedDateRange!.start.day.toString().padLeft(2, '0')}-${_selectedDateRange!.start.month.toString().padLeft(2, '0')}-${_selectedDateRange!.start.year} - ${_selectedDateRange!.end.day.toString().padLeft(2, '0')}-${_selectedDateRange!.end.month.toString().padLeft(2, '0')}-${_selectedDateRange!.end.year}")
          : '',
    );
    _locationController = TextEditingController(text: init?.location ?? '');
    _minPriceController = TextEditingController(
      text: init?.minPrice != null ? init!.minPrice!.toInt().toString() : '',
    );
    _maxPriceController = TextEditingController(
      text: init?.maxPrice != null ? init!.maxPrice!.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedDateRange = null;
      _dateController.clear();
      _locationController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _isOfflineSelected = false;
      _isOnlineSelected = false;
    });
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    final result = FilterData(
      categories: _selectedCategories,
      dateRange: _selectedDateRange,
      location: _locationController.text,
      minPrice: minPrice,
      maxPrice: maxPrice,
      isOffline: _isOfflineSelected,
      isOnline: _isOnlineSelected,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle Indicator
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header "Filter"
            Center(
              child: Text(
                'Filter',
                style: AppTextStyles.semiBold(20, AppColors.neutral950),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.neutral300, height: 1),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kategori
                  Text(
                    'Kategori',
                    style: AppTextStyles.semiBold(16, AppColors.neutral950),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      FilterTag(
                        label: 'Edukasi',
                        icon: TablerIcons.book,
                        isSelected: _selectedCategories.contains('Edukasi'),
                        onTap: () => _selectCategory('Edukasi'),
                      ),
                      FilterTag(
                        label: 'Hiburan & Festival',
                        icon: TablerIcons.ticket,
                        isSelected: _selectedCategories.contains(
                          'Hiburan & Festival',
                        ),
                        onTap: () => _selectCategory('Hiburan & Festival'),
                      ),
                      FilterTag(
                        label: 'Seni & Budaya',
                        icon: TablerIcons.palette,
                        isSelected: _selectedCategories.contains(
                          'Seni & Budaya',
                        ),
                        onTap: () => _selectCategory('Seni & Budaya'),
                      ),
                      FilterTag(
                        label: 'Olahraga',
                        icon: TablerIcons.ballBasketball,
                        isSelected: _selectedCategories.contains('Olahraga'),
                        onTap: () => _selectCategory('Olahraga'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Waktu
                  Text(
                    'Waktu',
                    style: AppTextStyles.semiBold(16, AppColors.neutral950),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _dateController,
                    hintText: 'Pilih tanggal',
                    readOnly: true,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        AppIcons.calendar,
                        color: AppColors.neutral300,
                        size: 20,
                      ),
                    ),
                    onTap: () async {
                      final picked = await DateRangeModal.show(
                        context,
                        initialRange: _selectedDateRange,
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateRange = picked;
                          final startDay = picked.start.day.toString().padLeft(
                            2,
                            '0',
                          );
                          final startMonth = picked.start.month
                              .toString()
                              .padLeft(2, '0');
                          final endDay = picked.end.day.toString().padLeft(
                            2,
                            '0',
                          );
                          final endMonth = picked.end.month.toString().padLeft(
                            2,
                            '0',
                          );

                          if (picked.start.day == picked.end.day &&
                              picked.start.month == picked.end.month &&
                              picked.start.year == picked.end.year) {
                            _dateController.text =
                                '$startDay-$startMonth-${picked.start.year}';
                          } else {
                            _dateController.text =
                                '$startDay-$startMonth-${picked.start.year} - $endDay-$endMonth-${picked.end.year}';
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // Lokasi
                  Text(
                    'Lokasi',
                    style: AppTextStyles.semiBold(16, AppColors.neutral950),
                  ),
                  const SizedBox(height: 8),
                  CustomInput(
                    controller: _locationController,
                    hintText: 'Lokasi',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        AppIcons.location,
                        color: AppColors.neutral300,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Harga
                  Text(
                    'Harga',
                    style: AppTextStyles.semiBold(16, AppColors.neutral950),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CustomInput(
                          controller: _minPriceController,
                          hintText: 'Terendah',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomInput(
                          controller: _maxPriceController,
                          hintText: 'Tertinggi',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Format
                  Text(
                    'Format',
                    style: AppTextStyles.semiBold(16, AppColors.neutral950),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Offline',
                          onPressed: () {
                            setState(() {
                              if (_isOfflineSelected) {
                                _isOfflineSelected = false;
                              } else {
                                _isOfflineSelected = true;
                                _isOnlineSelected = false;
                              }
                            });
                          },
                          backgroundColor: _isOfflineSelected
                              ? AppColors.sky500
                              : AppColors.neutral300,
                          textColor: _isOfflineSelected
                              ? Colors.white
                              : AppColors.neutral400,
                          isOutlined: !_isOfflineSelected,
                          size: CustomButtonSize.medium,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Online',
                          onPressed: () {
                            setState(() {
                              if (_isOnlineSelected) {
                                _isOnlineSelected = false;
                              } else {
                                _isOnlineSelected = true;
                                _isOfflineSelected = false;
                              }
                            });
                          },
                          backgroundColor: _isOnlineSelected
                              ? AppColors.sky500
                              : AppColors.neutral300,
                          textColor: _isOnlineSelected
                              ? Colors.white
                              : AppColors.neutral400,
                          isOutlined: !_isOnlineSelected,
                          size: CustomButtonSize.medium,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bottom Buttons (Terapkan & Reset)
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Terapkan',
                          onPressed: _applyFilters,
                          size: CustomButtonSize.large,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Reset',
                          onPressed: _resetFilters,
                          isOutlined: true,
                          backgroundColor: AppColors.sky500,
                          textColor: AppColors.sky500,
                          size: CustomButtonSize.large,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/events_cards/mid.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/event_tag.dart';
import '../../blocs/event_detail_bloc.dart';
import '../../models/event_detail_model.dart';
import '../../models/event_model.dart';
import '../Order/book_order.dart';

class EventDetailsView extends StatefulWidget {
  final String? eventId;
  final EventModel? event;

  const EventDetailsView({super.key, this.eventId, this.event});

  @override
  State<EventDetailsView> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends State<EventDetailsView> {
  late final EventDetailBloc _bloc;
  bool _isDescExpanded = false;
  bool _isTermsExpanded = false;
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _bloc = EventDetailBloc();
    _pageController = PageController();
    final id = widget.eventId ?? widget.event?.id;
    if (id != null) {
      _bloc.fetchEventDetail(id);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  String _formatDisplayDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final dayName = days[dt.weekday - 1];
      final monthName = months[dt.month - 1];
      return '$dayName, ${dt.day} $monthName ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  int _getLowestPrice(List<EventTicketTypeModel> ticketTypes) {
    if (ticketTypes.isEmpty) return 0;
    return ticketTypes
        .map((e) => e.price)
        .reduce((curr, next) => curr < next ? curr : next);
  }

  String _formatPrice(int price) {
    if (price <= 0) return 'Free';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp$formatted';
  }

  void _onBookEvent(EventDetailModel detail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookOrderView(eventDetail: detail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _bloc,
      builder: (context, _) {
        final detail = _bloc.eventDetail;

        if (_bloc.isLoading && widget.event == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.sky500),
            ),
          );
        }

        if (_bloc.status == EventDetailStatus.error && widget.event == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _bloc.errorMessage ?? 'Gagal memuat detail event.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regular(14, AppColors.neutral500),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final id = widget.eventId ?? widget.event?.id;
                        if (id != null) {
                          _bloc.fetchEventDetail(id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sky500,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Determine metadata based on available info
        final title = detail?.name ?? widget.event?.name ?? 'Detail Event';
        final category = detail?.category ?? widget.event?.category ?? '';
        final lowestPrice = detail != null
            ? _getLowestPrice(detail.ticketTypes)
            : (widget.event?.lowestPrice ?? 0);
        final priceText = _formatPrice(lowestPrice);

        // Build images list for carousel
        final images = <String>[];
        if (detail != null) {
          if (detail.galleries.isNotEmpty) {
            images.addAll(detail.galleries);
          } else if (detail.image16x9.isNotEmpty) {
            images.add(detail.image16x9);
          }
        } else if (widget.event != null && widget.event!.image.isNotEmpty) {
          images.add(widget.event!.image);
        }

        // Date and location parsing
        String dateText = '';
        String timeText = '';
        String venueText = '';
        String addressText = '';

        if (detail != null) {
          if (detail.schedules.isNotEmpty) {
            dateText = _formatDisplayDate(detail.schedules.first.date);
            timeText =
                '${detail.schedules.first.startTime} - ${detail.schedules.first.endTime}';
          }
          venueText = detail.location.venue;
          addressText = detail.location.address;
        } else if (widget.event != null) {
          dateText = _formatDisplayDate(widget.event!.schedule);
          timeText = '08.00 - 13.00';
          venueText = widget.event!.venue;
          addressText = widget.event!.venue;
        }

        // Expandable settings
        final desc = detail?.description ?? '';
        final showReadMore = desc.length > 200;

        final terms = detail?.termsConditions ?? [];
        final showReadMoreTerms = terms.length > 3;
        final itemsToShow = _isTermsExpanded
            ? terms.length
            : (terms.length > 3 ? 3 : terms.length);

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Carousel Header
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: images.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  AppConstants.resolveImageUrl(images[index]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppColors.neutral100,
                                        child: Icon(
                                          AppIcons.calendar,
                                          size: 48,
                                          color: AppColors.neutral400,
                                        ),
                                      ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.neutral100,
                              child: Icon(
                                AppIcons.calendar,
                                size: 48,
                                color: AppColors.neutral400,
                              ),
                            ),
                    ),
                    // Back Button Overlay
                    Positioned(
                      top: 16,
                      left: 16,
                      child: SafeArea(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              AppIcons.arrowNarrowLeft,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Carousel Dot Indicators
                    if (images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (index) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? AppColors.sky500
                                    : Colors.white.withValues(alpha: 0.6),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),

                // 2. Title & Category Tag
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.medium(24, AppColors.neutral950),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (category.isNotEmpty)
                        EventTag(
                          category: category,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                    ],
                  ),
                ),

                // 3. Date & Time Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.sky50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          AppIcons.calendar,
                          color: AppColors.sky500,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateText,
                              style: AppTextStyles.medium(
                                14,
                                AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeText,
                              style: AppTextStyles.regular(
                                12,
                                AppColors.neutral500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Location Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.sky50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          AppIcons.location,
                          color: AppColors.sky500,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venueText,
                              style: AppTextStyles.medium(
                                14,
                                AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addressText,
                              style: AppTextStyles.regular(
                                12,
                                AppColors.neutral500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Organizer section
                if (detail != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                    child: Divider(
                      color: AppColors.neutral300,
                      height: 1,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.neutral200,
                          backgroundImage: detail.organizer.photo.isNotEmpty
                              ? NetworkImage(
                                  AppConstants.resolveImageUrl(
                                    detail.organizer.photo,
                                  ),
                                )
                              : null,
                          child: detail.organizer.photo.isEmpty
                              ? Icon(
                                  AppIcons.profile,
                                  color: AppColors.neutral400,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.organizer.name,
                                style: AppTextStyles.medium(
                                  14,
                                  AppColors.neutral950,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Organizer',
                                style: AppTextStyles.regular(
                                  12,
                                  AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 6. Tentang event
                if (desc.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tentang event',
                          style: AppTextStyles.medium(16, AppColors.neutral950),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          desc,
                          maxLines: _isDescExpanded ? null : 4,
                          overflow: _isDescExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: AppTextStyles.regular(
                            14,
                            AppColors.neutral600,
                          ).copyWith(height: 1.5),
                        ),
                        if (showReadMore) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isDescExpanded = !_isDescExpanded,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isDescExpanded
                                      ? 'Lihat lebih sedikit'
                                      : 'Lihat lebih',
                                  style: AppTextStyles.medium(
                                    14,
                                    AppColors.sky500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isDescExpanded
                                      ? AppIcons.chevronUp
                                      : AppIcons.chevronDown,
                                  size: 16,
                                  color: AppColors.sky500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 7. Ketentuan
                if (terms.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ketentuan',
                          style: AppTextStyles.medium(16, AppColors.neutral950),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(itemsToShow, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: AppTextStyles.regular(
                                    14,
                                    AppColors.neutral600,
                                  ).copyWith(height: 1.5),
                                ),
                                Expanded(
                                  child: Text(
                                    terms[index],
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.neutral600,
                                    ).copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (showReadMoreTerms) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isTermsExpanded = !_isTermsExpanded,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isTermsExpanded
                                      ? 'Lihat lebih sedikit'
                                      : 'Lihat lebih',
                                  style: AppTextStyles.medium(
                                    14,
                                    AppColors.sky500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  _isTermsExpanded
                                      ? AppIcons.chevronUp
                                      : AppIcons.chevronDown,
                                  size: 16,
                                  color: AppColors.sky500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // 8. Location Map Section
                if (detail != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: GestureDetector(
                      onTap: () async {
                        final mapLink = detail.location.mapLink;
                        if (mapLink.isNotEmpty) {
                          final uri = Uri.parse(mapLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: AppTextStyles.medium(
                              16,
                              AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                AppIcons.location,
                                size: 16,
                                color: AppColors.neutral600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  addressText,
                                  style: AppTextStyles.regular(
                                    14,
                                    AppColors.neutral600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  'https://static-maps.yandex.ru/1.x/?lang=en_US&ll=106.7288,-6.5593&z=14&l=map&size=600,300',
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: AppColors.neutral100,
                                      child: Icon(
                                        Icons.map,
                                        size: 48,
                                        color: AppColors.neutral400,
                                      ),
                                    );
                                  },
                                ),
                                Container(
                                  height: 150,
                                  color: Colors.black.withValues(alpha: 0.05),
                                ),
                                Icon(
                                  AppIcons.location,
                                  size: 40,
                                  color: AppColors.red500,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // 9. Recommended events "Event lainnya"
                if (detail != null && detail.otherEvents.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Event lainnya',
                            style: AppTextStyles.medium(
                              16,
                              AppColors.neutral950,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: detail.otherEvents.map((otherEvent) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EventDetailsView(
                                          eventId: otherEvent.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: EventCardMid(
                                    title: otherEvent.name,
                                    organizerName: otherEvent.organizerName,
                                    date: otherEvent.schedule,
                                    location: otherEvent.venue,
                                    price: otherEvent.formattedPrice,
                                    imageUrl: AppConstants.resolveImageUrl(
                                      otherEvent.image,
                                    ),
                                    organizerImageUrl:
                                        AppConstants.resolveImageUrl(
                                          otherEvent.organizerPhoto,
                                        ),
                                    category: otherEvent.category,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Spacing at the bottom of the body
                const SizedBox(height: 24),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: AppColors.neutral200),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Mulai dari',
                        style: AppTextStyles.medium(
                          12,
                          AppColors.neutral950,
                        ).copyWith(height: 1.0),
                      ),
                      Text(
                        priceText,
                        style: AppTextStyles.semiBold(24, AppColors.sky500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Book Event',
                    size: CustomButtonSize.large,
                    onPressed: detail != null
                        ? () => _onBookEvent(detail)
                        : null,
                    isDisabled: detail == null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

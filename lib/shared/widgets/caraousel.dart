import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_theme.dart';
import 'caraousel_indicator.dart';

class CustomCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const CustomCarousel({super.key, required this.images, this.height = 150});

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  late int _currentIndex;
  late PageController _pageController;
  Timer? _timer;

  // A large number to simulate infinite scrolling
  final int _infiniteItemCount = 10000;

  @override
  void initState() {
    super.initState();
    // Start in the middle of the large item count
    _currentIndex = 0;
    _pageController = PageController(
      initialPage:
          (_infiniteItemCount ~/ 2) -
          ((_infiniteItemCount ~/ 2) %
              (widget.images.isNotEmpty ? widget.images.length : 1)),
    );
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
          if (_pageController.hasClients) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index % widget.images.length;
              });
            },
            itemCount: _infiniteItemCount,
            itemBuilder: (context, index) {
              final realIndex = index % widget.images.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.images[realIndex],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.neutral100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.sky500,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.neutral100,
                        child: const Icon(
                          Icons.error_outline,
                          color: AppColors.neutral300,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        CarouselIndicator(
          currentIndex: _currentIndex,
          itemCount: widget.images.length,
        ),
      ],
    );
  }
}

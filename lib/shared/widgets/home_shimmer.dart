import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class SkeletonPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<SkeletonPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity:
              0.3 + (_controller.value * 0.4), // pulses between 0.3 and 0.7
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: widget.borderRadius,
            ),
          ),
        );
      },
    );
  }
}

class ShimmerCardMid extends StatelessWidget {
  const ShimmerCardMid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image skeleton
          const SkeletonPlaceholder(
            width: double.infinity,
            height: 130,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                const SkeletonPlaceholder(width: 180, height: 16),
                const SizedBox(height: 6),
                const SkeletonPlaceholder(width: 120, height: 16),
                const SizedBox(height: 16),

                // Organizer skeleton
                const Row(
                  children: [
                    SkeletonPlaceholder(
                      width: 16,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 80, height: 12),
                  ],
                ),
                const SizedBox(height: 12),

                // Date & Location skeleton
                const Row(
                  children: [
                    SkeletonPlaceholder(width: 16, height: 16),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 120, height: 12),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    SkeletonPlaceholder(width: 16, height: 16),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 100, height: 12),
                  ],
                ),
                const SizedBox(height: 16),

                // Price skeleton
                Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SkeletonPlaceholder(width: 50, height: 10),
                      const SizedBox(height: 4),
                      SkeletonPlaceholder(
                        width: 70,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
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

class ShimmerCardSmall extends StatelessWidget {
  const ShimmerCardSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300, width: 1),
      ),
      padding: const EdgeInsets.all(8),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Image skeleton
          SkeletonPlaceholder(
            width: 100,
            height: 100,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          SizedBox(width: 12),
          // Right: Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonPlaceholder(
                  width: 50,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 8),
                SkeletonPlaceholder(width: double.infinity, height: 16),
                SizedBox(height: 6),
                SkeletonPlaceholder(width: 120, height: 16),
                SizedBox(height: 12),
                Row(
                  children: [
                    SkeletonPlaceholder(
                      width: 16,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 80, height: 12),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonPlaceholder(width: 16, height: 16),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 100, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title 1
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SkeletonPlaceholder(
            width: 180,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal scrolling card list
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 16),
                child: ShimmerCardMid(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Title 2
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SkeletonPlaceholder(
            width: 120,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 16),

        // Vertical column list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerCardSmall(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

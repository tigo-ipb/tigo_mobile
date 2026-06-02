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

// ─────────────────────────────────────────────
// EXPLORE SHIMMER
// ─────────────────────────────────────────────

/// Skeleton card besar untuk halaman Explore (mirip EventCardLarge).
class ShimmerCardLarge extends StatelessWidget {
  const ShimmerCardLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          SkeletonPlaceholder(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                SkeletonPlaceholder(
                  width: 70,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 10),
                // Title
                SkeletonPlaceholder(width: double.infinity, height: 16),
                SizedBox(height: 6),
                SkeletonPlaceholder(width: 200, height: 16),
                SizedBox(height: 14),
                // Organizer
                Row(
                  children: [
                    SkeletonPlaceholder(
                      width: 20,
                      height: 20,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 100, height: 12),
                  ],
                ),
                SizedBox(height: 8),
                // Date
                Row(
                  children: [
                    SkeletonPlaceholder(width: 16, height: 16),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 130, height: 12),
                  ],
                ),
                SizedBox(height: 8),
                // Location
                Row(
                  children: [
                    SkeletonPlaceholder(width: 16, height: 16),
                    SizedBox(width: 8),
                    SkeletonPlaceholder(width: 110, height: 12),
                  ],
                ),
                SizedBox(height: 14),
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonPlaceholder(width: 80, height: 14),
                    SkeletonPlaceholder(
                      width: 90,
                      height: 32,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
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

/// Shimmer untuk halaman Explore — daftar vertikal `ShimmerCardLarge`.
class ExploreShimmer extends StatelessWidget {
  const ExploreShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (_, _) => const ShimmerCardLarge(),
    );
  }
}

// ─────────────────────────────────────────────
// TICKET SHIMMER
// ─────────────────────────────────────────────

/// Skeleton satu baris tiket (mirip TicketCard).
class ShimmerTicketCard extends StatelessWidget {
  const ShimmerTicketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          SkeletonPlaceholder(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                SkeletonPlaceholder(
                  width: 60,
                  height: 18,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 8),
                // Event name
                SkeletonPlaceholder(width: double.infinity, height: 15),
                SizedBox(height: 6),
                SkeletonPlaceholder(width: 140, height: 15),
                SizedBox(height: 10),
                // Date
                Row(
                  children: [
                    SkeletonPlaceholder(width: 14, height: 14),
                    SizedBox(width: 6),
                    SkeletonPlaceholder(width: 110, height: 12),
                  ],
                ),
                SizedBox(height: 6),
                // Location
                Row(
                  children: [
                    SkeletonPlaceholder(width: 14, height: 14),
                    SizedBox(width: 6),
                    SkeletonPlaceholder(width: 90, height: 12),
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

/// Shimmer untuk halaman Tiket — daftar vertikal `ShimmerTicketCard`.
class TicketShimmer extends StatelessWidget {
  const TicketShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) => const ShimmerTicketCard(),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE SHIMMER
// ─────────────────────────────────────────────

/// Shimmer untuk halaman Profile.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title "Profile"
          const SkeletonPlaceholder(
            width: 90,
            height: 28,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          const SizedBox(height: 28),

          // Avatar + Name
          Center(
            child: Column(
              children: [
                const SkeletonPlaceholder(
                  width: 110,
                  height: 110,
                  borderRadius: BorderRadius.all(Radius.circular(55)),
                ),
                const SizedBox(height: 16),
                const SkeletonPlaceholder(
                  width: 140,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                const SizedBox(height: 8),
                SkeletonPlaceholder(
                  width: 100,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Edit + Share buttons
          const Row(
            children: [
              Expanded(
                child: SkeletonPlaceholder(
                  width: double.infinity,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SkeletonPlaceholder(
                  width: double.infinity,
                  height: 44,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Menu card skeleton
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              children: List.generate(3, (index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          const SkeletonPlaceholder(
                            width: 40,
                            height: 40,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          const SizedBox(width: 16),
                          SkeletonPlaceholder(
                            width: 80 + (index * 20).toDouble(),
                            height: 14,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                          const Spacer(),
                          const SkeletonPlaceholder(
                            width: 16,
                            height: 16,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ],
                      ),
                    ),
                    if (index < 2)
                      const Divider(
                        color: AppColors.neutral200,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 28),

          // Logout button
          const SkeletonPlaceholder(
            width: double.infinity,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ORGANIZER DASHBOARD SHIMMER
// ─────────────────────────────────────────────

/// Shimmer untuk halaman Dashboard Organizer.
class OrganizerDashboardShimmer extends StatelessWidget {
  const OrganizerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Header: Title + counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonPlaceholder(
                  width: 120,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                SizedBox(height: 6),
                SkeletonPlaceholder(
                  width: 160,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
            SkeletonPlaceholder(
              width: 80,
              height: 28,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Progress card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            children: List.generate(2, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == 1 ? 0 : 16),
                child: const Row(
                  children: [
                    SkeletonPlaceholder(
                      width: 60,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SkeletonPlaceholder(
                        width: double.infinity,
                        height: 28,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 32),

        // "Scan terakhir" title
        const SkeletonPlaceholder(
          width: 130,
          height: 20,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        const SizedBox(height: 16),

        // Recent scans table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neutral200),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              // Table header
              const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: SkeletonPlaceholder(
                      width: 60,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: SkeletonPlaceholder(
                        width: 50,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SkeletonPlaceholder(
                        width: 40,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.neutral200, height: 1),
              const SizedBox(height: 8),

              // Table rows
              ...List.generate(5, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Col 1: order + name
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonPlaceholder(
                              width: 70 + (index % 3 * 10).toDouble(),
                              height: 12,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SkeletonPlaceholder(
                              width: 80 + (index % 2 * 15).toDouble(),
                              height: 14,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Col 2: date + time
                      const Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SkeletonPlaceholder(
                              width: 55,
                              height: 12,
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            SizedBox(height: 4),
                            SkeletonPlaceholder(
                              width: 35,
                              height: 14,
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Col 3: event + category
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SkeletonPlaceholder(
                              width: 60 + (index % 3 * 10).toDouble(),
                              height: 14,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SkeletonPlaceholder(
                              width: 45,
                              height: 12,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

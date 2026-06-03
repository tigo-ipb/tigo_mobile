import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../../../../core/constants/app_theme.dart';
import '../../models/organizer_dashboard_model.dart';

class OrganizerDashboardView extends StatelessWidget {
  final OrganizerDashboardModel dashboardData;
  final bool isLoading;

  const OrganizerDashboardView({
    super.key,
    required this.dashboardData,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      children: [
        // Header Row: Title and Counter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengunjung',
                    style: AppTextStyles.semiBold(24, AppColors.neutral950),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dashboardData.eventName,
                    style: AppTextStyles.regular(12, AppColors.neutral400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                if (isLoading) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.sky500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${dashboardData.totalScanned} ',
                        style: AppTextStyles.bold(24, AppColors.sky500),
                      ),
                      TextSpan(
                        text: '/ ${dashboardData.totalSold}',
                        style: AppTextStyles.medium(24, AppColors.neutral300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Statistics Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Column(
            children: dashboardData.breakdown.isEmpty
                ? [
                    Text(
                      'Belum ada data breakdown tiket.',
                      style: AppTextStyles.regular(14, AppColors.neutral400),
                    ),
                  ]
                : List.generate(dashboardData.breakdown.length, (index) {
                    final item = dashboardData.breakdown[index];
                    // Unscanned count is sold - scanned
                    final remaining = (item.sold - item.scanned).clamp(
                      0,
                      item.sold,
                    );
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == dashboardData.breakdown.length - 1
                            ? 0.0
                            : 16.0,
                      ),
                      child: _buildProgressBarRow(
                        item.typeName,
                        item.scanned,
                        remaining,
                        item.sold,
                      ),
                    );
                  }),
          ),
        ),
        const SizedBox(height: 32),

        // Scan Terakhir Section
        Text(
          'Scan terakhir',
          style: AppTextStyles.semiBold(20, AppColors.neutral950),
        ),
        const SizedBox(height: 16),

        // Recent Scans Table Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.neutral300),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              // Table Header
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order ID',
                        style: AppTextStyles.semiBold(14, AppColors.sky500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Waktu',
                        style: AppTextStyles.semiBold(14, AppColors.sky500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Event',
                        style: AppTextStyles.semiBold(14, AppColors.sky500),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.neutral200),

              // Table Rows
              dashboardData.recentScans.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'Belum ada scan yang dilakukan.',
                        style: AppTextStyles.regular(14, AppColors.neutral400),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dashboardData.recentScans.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.neutral100,
                        height: 16,
                      ),
                      itemBuilder: (context, index) {
                        final item = dashboardData.recentScans[index];
                        final isFailed = item.status.toUpperCase() == 'FAILED';

                        // Parse date and time from scanned_at (e.g. "02/06/2026 06:08")
                        String date = '';
                        String time = '';
                        if (item.scannedAt.contains(' ')) {
                          final parts = item.scannedAt.split(' ');
                          date = parts[0];
                          time = parts[1];
                        } else {
                          date = item.scannedAt;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column 1: Order ID & Name (with dynamic fail styling)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (isFailed) ...[
                                          const Icon(
                                            TablerIcons.circleXFilled,
                                            color: AppColors.red500,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Expanded(
                                          child: Text(
                                            item.orderId,
                                            style: AppTextStyles.regular(
                                              12,
                                              isFailed
                                                  ? AppColors.red400
                                                  : AppColors.neutral400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.buyerName,
                                      style: AppTextStyles.medium(
                                        14,
                                        isFailed
                                            ? AppColors.red700
                                            : AppColors.neutral900,
                                      ),
                                    ),
                                    if (isFailed && item.reason.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.reason,
                                        style: AppTextStyles.medium(
                                          11,
                                          AppColors.red500,
                                        ).copyWith(fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Column 2: Date & Time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date,
                                      style: AppTextStyles.regular(
                                        12,
                                        isFailed
                                            ? AppColors.red400
                                            : AppColors.neutral400,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      time,
                                      style: AppTextStyles.medium(
                                        14,
                                        isFailed
                                            ? AppColors.red700
                                            : AppColors.neutral900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Column 3: Event & Category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.eventName,
                                      style: AppTextStyles.semiBold(
                                        14,
                                        isFailed
                                            ? AppColors.red700
                                            : AppColors.neutral900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.category,
                                      style: AppTextStyles.regular(
                                        12,
                                        isFailed
                                            ? AppColors.red400
                                            : AppColors.neutral400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBarRow(
    String label,
    int value,
    int remaining,
    int total,
  ) {
    final double percentage = total > 0 ? (value / total) : 0.0;

    return Row(
      children: [
        // Label
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.medium(14, AppColors.neutral900),
          ),
        ),
        const SizedBox(width: 8),

        // Custom stylized progress bar
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double barWidth = constraints.maxWidth;
              final double activeWidth = barWidth * percentage;

              return Container(
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.sky50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    // Active (Blue) section
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: activeWidth,
                        decoration: BoxDecoration(
                          color: AppColors.sky500,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    // Labels on top
                    Positioned.fill(
                      child: Row(
                        children: [
                          // Active Label (Left-aligned inside active bar)
                          SizedBox(
                            width: activeWidth > 0 ? activeWidth : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: activeWidth > 40
                                    ? Text(
                                        '$value',
                                        style: AppTextStyles.semiBold(
                                          12,
                                          Colors.white,
                                        ),
                                        maxLines: 1,
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ),
                          ),

                          // Remaining Label (Right-aligned outside active bar)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '$remaining',
                                  style: AppTextStyles.medium(
                                    12,
                                    AppColors.neutral950,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../shared/widgets/payment_status.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';

class TicketDetailsView extends StatelessWidget {
  const TicketDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.arrowNarrowLeft,
                          size: 24,
                          color: AppColors.neutral950,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kembali',
                          style: AppTextStyles.medium(16, AppColors.neutral950),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // 1. QR Code Card
                    _buildCard(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 280,
                            padding: const EdgeInsets.all(20),
                            child: Image.network(
                              'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=TIGO-TICKET-2026-EXAMPLE',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Event Details Card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            'Nama event',
                            'AGSN 2026',
                            isTitle: true,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Tanggal dan Jam',
                            'Senin, 1 Agustus • 08.00 - 13.00',
                            isTitle: true,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Lokasi',
                            'Telaga Inspirasi, IPB University, Babakan',
                            isTitle: true,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Organizer',
                            'IPB University',
                            isTitle: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. User Details Card
                    _buildCard(
                      child: Column(
                        children: [
                          _buildDetailRow('Nama', 'Aryo Ristiawan Machfudz'),
                          _buildDetailRow('Tanggal lahir', '15-12-2005'),
                          _buildDetailRow('No. Handphone', '+62 85765677963'),
                          _buildDetailRow(
                            'Email',
                            'aryoristiawan@apps.ipb.ac.id',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Pricing Details Card
                    _buildCard(
                      child: Column(
                        children: [
                          _buildDetailRow('2 Ticket (IPB Student)', 'Rp.0'),
                          _buildDetailRow('2 Ticket (General)', 'Rp.100.000'),
                          const Divider(
                            color: AppColors.neutral200,
                            height: 32,
                          ),
                          _buildDetailRow('Total', 'Rp.100.000', isTotal: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Payment Info Card
                    _buildCard(
                      child: Column(
                        children: [
                          _buildDetailRow('Metode pembayaran', 'Qris'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status',
                                style: AppTextStyles.regular(
                                  14,
                                  AppColors.neutral500,
                                ),
                              ),
                              const PaymentStatusTag(
                                status: PaymentStatus.paid,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isTitle = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.regular(12, AppColors.neutral500)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.medium(14, AppColors.neutral950)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.regular(14, AppColors.neutral500)),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.semiBold(14, AppColors.neutral950)
                : AppTextStyles.medium(14, AppColors.neutral950),
          ),
        ],
      ),
    );
  }
}

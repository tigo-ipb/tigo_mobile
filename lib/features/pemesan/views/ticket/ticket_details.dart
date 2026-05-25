import 'package:flutter/material.dart';
import '../../../../shared/widgets/payment_status.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../blocs/ticket_bloc.dart';

class TicketDetailsView extends StatefulWidget {
  final String paymentId;

  const TicketDetailsView({
    super.key,
    required this.paymentId,
  });

  @override
  State<TicketDetailsView> createState() => _TicketDetailsViewState();
}

class _TicketDetailsViewState extends State<TicketDetailsView> {
  late final TicketBloc _ticketBloc;

  @override
  void initState() {
    super.initState();
    _ticketBloc = TicketBloc();
    _ticketBloc.fetchTicketDetail(widget.paymentId);
  }

  @override
  void dispose() {
    _ticketBloc.dispose();
    super.dispose();
  }

  PaymentStatus _parsePaymentStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'paid':
      case 'success':
      case 'dibayar':
      case 'settlement':
        return PaymentStatus.paid;
      case 'pending':
      case 'menunggu':
        return PaymentStatus.pending;
      case 'cancelled':
      case 'failed':
      case 'dibatalkan':
      default:
        return PaymentStatus.cancelled;
    }
  }

  String _formatPrice(int amount) {
    if (amount <= 0) return 'Gratis';
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

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
              child: ListenableBuilder(
                listenable: _ticketBloc,
                builder: (context, _) {
                  if (_ticketBloc.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.sky500,
                      ),
                    );
                  }

                  if (_ticketBloc.status == TicketStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _ticketBloc.errorMessage ??
                                  'Gagal memuat detail tiket.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.regular(
                                14,
                                AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _ticketBloc.fetchTicketDetail(
                                widget.paymentId,
                              ),
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

                  final detail = _ticketBloc.currentDetail;

                  if (detail == null) {
                    return Center(
                      child: Text(
                        'Tiket tidak ditemukan.',
                        style: AppTextStyles.regular(
                          14,
                          AppColors.neutral500,
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
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
                              if (detail.qrCodes.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                    child: Text(
                                      'QR Code tidak tersedia',
                                      style: AppTextStyles.medium(
                                        14,
                                        AppColors.neutral400,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                SizedBox(
                                  height: 310,
                                  child: PageView.builder(
                                    itemCount: detail.qrCodes.length,
                                    itemBuilder: (context, index) {
                                      final qr = detail.qrCodes[index];
                                      final qrUrl =
                                          'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(qr.qrCodeString)}';
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 250,
                                            height: 250,
                                            padding: const EdgeInsets.all(10),
                                            child: Image.network(
                                              qrUrl,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tiket ${index + 1} dari ${detail.qrCodes.length} (${qr.isUsed ? 'Sudah Digunakan' : 'Belum Digunakan'})',
                                            style: AppTextStyles.medium(
                                              12,
                                              qr.isUsed
                                                  ? AppColors.neutral400
                                                  : AppColors.sky500,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
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
                                detail.eventName,
                                isTitle: true,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Tanggal dan Jam',
                                detail.eventDetails['schedule'] ??
                                    'Tanggal TBA',
                                isTitle: true,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Lokasi',
                                detail.venueName,
                                isTitle: true,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                'Organizer',
                                detail.eventDetails['organizer_name'] ??
                                    'Organizer',
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
                              _buildDetailRow(
                                'Nama',
                                detail.buyerDetails['name'] ?? '-',
                              ),
                              _buildDetailRow(
                                'Tanggal lahir',
                                detail.buyerDetails['birth_date'] ?? '-',
                              ),
                              _buildDetailRow(
                                'No. Handphone',
                                detail.buyerDetails['phone_number'] ?? '-',
                              ),
                              _buildDetailRow(
                                'Email',
                                detail.buyerDetails['email'] ?? '-',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Pricing Details Card
                        _buildCard(
                          child: Column(
                            children: [
                              ...detail.ticketItems.map((item) {
                                final label =
                                    '${item.quantity} Ticket (${item.typeName})';
                                return _buildDetailRow(
                                  label,
                                  _formatPrice(item.price),
                                );
                              }),
                              const Divider(
                                color: AppColors.neutral200,
                                height: 32,
                              ),
                              _buildDetailRow(
                                'Total',
                                _formatPrice(detail.totalPaid),
                                isTotal: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 5. Payment Info Card
                        _buildCard(
                          child: Column(
                            children: [
                              _buildDetailRow(
                                'Metode pembayaran',
                                detail.eventDetails['payment_method'] ?? 'QRIS',
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status',
                                    style: AppTextStyles.regular(
                                      14,
                                      AppColors.neutral500,
                                    ),
                                  ),
                                  PaymentStatusTag(
                                    status: _parsePaymentStatus(detail.status),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
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

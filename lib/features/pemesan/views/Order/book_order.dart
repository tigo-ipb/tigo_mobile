import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../blocs/checkout_bloc.dart';
import '../../models/event_detail_model.dart';

class BookOrderView extends StatefulWidget {
  final EventDetailModel eventDetail;

  const BookOrderView({super.key, required this.eventDetail});

  @override
  State<BookOrderView> createState() => _BookOrderViewState();
}

class _BookOrderViewState extends State<BookOrderView> {
  late final CheckoutBloc _checkoutBloc;
  final Map<String, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _checkoutBloc = CheckoutBloc();
  }

  @override
  void dispose() {
    _checkoutBloc.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    if (price <= 0) return 'Gratis';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  void _increment(String typeId, int stock) => setState(() {
    final cur = _quantities[typeId] ?? 0;
    if (cur < stock) {
      _quantities[typeId] = cur + 1;
    }
  });

  void _decrement(String typeId) => setState(() {
    final cur = _quantities[typeId] ?? 0;
    if (cur > 0) _quantities[typeId] = cur - 1;
  });

  int get _totalItems => _quantities.values.fold(0, (sum, q) => sum + q);

  int get _totalPrice {
    int sum = 0;
    for (final ticket in widget.eventDetail.ticketTypes) {
      sum += ticket.price * (_quantities[ticket.typeId] ?? 0);
    }
    return sum;
  }

  Future<void> _onCheckout() async {
    final items = _quantities.entries
        .where((e) => e.value > 0)
        .map((e) => TicketOrderItem(typeId: e.key, quantity: e.value))
        .toList();

    if (items.isEmpty) return;

    final success = await _checkoutBloc.checkout(
      eventId: widget.eventDetail.id,
      ticketItems: items,
    );

    if (!mounted) return;

    if (success) {
      final result = _checkoutBloc.result;
      if (result != null && result.paymentUrl != null) {
        final uri = Uri.tryParse(result.paymentUrl!);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } else {
        _showSuccessDialog();
      }
    } else {
      _showErrorSnackBar(_checkoutBloc.errorMessage ?? 'Checkout gagal.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Tiket Berhasil Dipesan!',
          style: AppTextStyles.semiBold(16, AppColors.neutral900),
        ),
        content: Text(
          'Tiket gratis kamu telah berhasil dipesan. Cek di halaman tiket.',
          style: AppTextStyles.regular(13, AppColors.neutral600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back to details
            },
            child: Text(
              'OK',
              style: AppTextStyles.semiBold(13, AppColors.sky500),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.regular(13, Colors.white)),
        backgroundColor: AppColors.red500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.eventDetail;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(AppIcons.arrowNarrowLeft, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pemesanan Tiket',
          style: AppTextStyles.semiBold(16, AppColors.neutral900),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Event Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              AppConstants.resolveImageUrl(detail.image1x1),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.neutral100,
                                    child: Icon(
                                      TablerIcons.photo,
                                      color: AppColors.neutral400,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.name,
                                  style: AppTextStyles.semiBold(
                                    16,
                                    AppColors.neutral900,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      TablerIcons.calendar,
                                      size: 14,
                                      color: AppColors.sky500,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        detail.schedules.isNotEmpty
                                            ? _formatDisplayDate(
                                                detail.schedules.first.date,
                                              )
                                            : '',
                                        style: AppTextStyles.regular(
                                          12,
                                          AppColors.neutral600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      TablerIcons.mapPin,
                                      size: 14,
                                      color: AppColors.sky500,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        detail.location.venue,
                                        style: AppTextStyles.regular(
                                          12,
                                          AppColors.neutral600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 24),

                    // Ticket Section Title
                    Text(
                      'Pilih Tipe Tiket',
                      style: AppTextStyles.semiBold(16, AppColors.neutral900),
                    ),
                    const SizedBox(height: 12),

                    // Ticket List
                    ...detail.ticketTypes.map((ticket) {
                      final qty = _quantities[ticket.typeId] ?? 0;
                      final isSoldOut = ticket.availableStock <= 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: qty > 0
                                ? AppColors.sky500
                                : AppColors.neutral200,
                            width: qty > 0 ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ticket.typeName,
                                    style: AppTextStyles.semiBold(
                                      14,
                                      isSoldOut
                                          ? AppColors.neutral400
                                          : AppColors.neutral900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPrice(ticket.price),
                                    style: AppTextStyles.medium(
                                      14,
                                      isSoldOut
                                          ? AppColors.neutral400
                                          : AppColors.sky600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (isSoldOut)
                                    Text(
                                      'Habis Terjual',
                                      style: AppTextStyles.regular(
                                        12,
                                        AppColors.red500,
                                      ),
                                    )
                                  else if (ticket.availableStock < 10)
                                    Text(
                                      'Sisa ${ticket.availableStock} tiket',
                                      style: AppTextStyles.regular(
                                        12,
                                        AppColors.yellow600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (!isSoldOut)
                              Row(
                                children: [
                                  _QtyButton(
                                    icon: TablerIcons.minus,
                                    onTap: qty > 0
                                        ? () => _decrement(ticket.typeId)
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 36,
                                    child: Text(
                                      '$qty',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.semiBold(
                                        16,
                                        AppColors.neutral900,
                                      ),
                                    ),
                                  ),
                                  _QtyButton(
                                    icon: TablerIcons.plus,
                                    onTap: qty < ticket.availableStock
                                        ? () => _increment(
                                            ticket.typeId,
                                            ticket.availableStock,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }),

                    // Extra spacing at the bottom for the fixed bottom bar
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _checkoutBloc,
              builder: (context, _) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(
                      top: BorderSide(color: AppColors.neutral200),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
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
                              'Total Bayar ($_totalItems tiket)',
                              style: AppTextStyles.regular(
                                12,
                                AppColors.neutral500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatPrice(_totalPrice),
                              style: AppTextStyles.bold(
                                18,
                                AppColors.neutral950,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Bayar Sekarang',
                          size: CustomButtonSize.large,
                          isDisabled: _totalItems == 0,
                          isLoading: _checkoutBloc.isLoading,
                          onPressed: _onCheckout,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.sky50 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppColors.sky300 : AppColors.neutral200,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.sky600 : AppColors.neutral300,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/book_card_ticket.dart';
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

  String _formatPrice(int price, {bool showFree = false}) {
    if (price <= 0) return showFree ? 'Free' : 'Rp.0';
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp.$formatted';
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
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neutral300),
        ),
        title: Text(
          'Tiket Berhasil Dipesan!',
          style: AppTextStyles.medium(16, AppColors.neutral900),
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
              style: AppTextStyles.medium(13, AppColors.sky500),
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

    final selectedTickets = detail.ticketTypes
        .where((t) => (_quantities[t.typeId] ?? 0) > 0)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            AppIcons.arrowNarrowLeft,
            color: AppColors.neutral950,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Text(
          'Book Event',
          style: AppTextStyles.medium(16, AppColors.neutral950),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tipe tiket Title
            Text(
              'Tipe tiket',
              style: AppTextStyles.medium(18, AppColors.neutral950),
            ),
            const SizedBox(height: 16),

            // 2. Ticket Cards List
            ...detail.ticketTypes.map((ticket) {
              final qty = _quantities[ticket.typeId] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BookCardTicket(
                  name: ticket.typeName,
                  price: ticket.price,
                  quantity: qty,
                  availableStock: ticket.availableStock,
                  description: ticket.description,
                  onIncrement: () =>
                      _increment(ticket.typeId, ticket.availableStock),
                  onDecrement: () => _decrement(ticket.typeId),
                ),
              );
            }),
            const SizedBox(height: 8),

            // 3. Details Section
            Text(
              'Details',
              style: AppTextStyles.medium(18, AppColors.neutral950),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Column(
                children: [
                  if (selectedTickets.isNotEmpty) ...[
                    ...selectedTickets.map((t) {
                      final qty = _quantities[t.typeId] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$qty Ticket (${t.typeName})',
                              style: AppTextStyles.regular(
                                14,
                                AppColors.neutral600,
                              ),
                            ),
                            Text(
                              _formatPrice(t.price * qty),
                              style: AppTextStyles.medium(
                                14,
                                AppColors.neutral950,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(color: AppColors.neutral300, height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.medium(14, AppColors.neutral950),
                      ),
                      Text(
                        _formatPrice(_totalPrice),
                        style: AppTextStyles.medium(14, AppColors.neutral950),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: ListenableBuilder(
          listenable: _checkoutBloc,
          builder: (context, _) {
            return CustomButton(
              text:
                  'Continue - ${_totalPrice == 0 ? 'Rp.0.000' : _formatPrice(_totalPrice)}',
              size: CustomButtonSize.large,
              isDisabled: _totalItems == 0,
              isLoading: _checkoutBloc.isLoading,
              onPressed: _onCheckout,
            );
          },
        ),
      ),
    );
  }
}

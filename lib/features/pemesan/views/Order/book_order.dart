import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/book_card_ticket.dart';
import '../../blocs/checkout_bloc.dart';
import '../../models/event_detail_model.dart';
import 'ticket_identity.dart';

class BookOrderView extends StatefulWidget {
  final EventDetailModel eventDetail;

  const BookOrderView({super.key, required this.eventDetail});

  @override
  State<BookOrderView> createState() => _BookOrderViewState();
}

class _BookOrderViewState extends State<BookOrderView> {
  final Map<String, int> _quantities = {};

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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: Icon(
              AppIcons.arrowNarrowLeft,
              color: AppColors.neutral950,
              size: 24,
            ),
          ),
        ),
        leadingWidth: 44,
        titleSpacing: 8,
        title: Text(
          'Book Event',
          style: AppTextStyles.medium(16, AppColors.neutral950),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 8,
            bottom: 16,
          ),
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
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: CustomButton(
          text:
              'Continue - ${_totalPrice == 0 ? 'Rp.0.000' : _formatPrice(_totalPrice)}',
          size: CustomButtonSize.large,
          isDisabled: _totalItems == 0,
          onPressed: () {
            final items = _quantities.entries
                .where((e) => e.value > 0)
                .map((e) => TicketOrderItem(typeId: e.key, quantity: e.value))
                .toList();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketIdentityView(
                  eventDetail: widget.eventDetail,
                  ticketItems: items,
                  totalPrice: _totalPrice,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

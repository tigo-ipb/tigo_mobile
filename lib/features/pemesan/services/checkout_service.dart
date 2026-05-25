import '../models/checkout_model.dart';
import 'api_client.dart';

class TicketOrderItem {
  final String typeId;
  final int quantity;

  TicketOrderItem({required this.typeId, required this.quantity});

  Map<String, dynamic> toJson() => {'type_id': typeId, 'quantity': quantity};
}

class CheckoutService {
  /// POST /checkout
  ///
  /// [eventId]     : ID event yang ingin dibeli tiketnya
  /// [ticketItems] : List tipe tiket + jumlah yang dipilih
  ///
  /// Jika tiket gratis → data.paymentUrl == null
  /// Jika tiket berbayar → data.paymentUrl berisi link Xendit
  static Future<CheckoutResultModel> checkout({
    required String eventId,
    required List<TicketOrderItem> ticketItems,
  }) async {
    final res = await ApiClient.post(
      '/checkout',
      body: {
        'event_id': eventId,
        'ticket_items': ticketItems.map((e) => e.toJson()).toList(),
      },
    );

    return CheckoutResultModel.fromJson(res['data']);
  }
}

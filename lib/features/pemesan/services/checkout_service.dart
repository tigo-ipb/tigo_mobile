import 'dart:developer' as developer;
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
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerBirthDate,
  }) async {
    final reqBody = {
      'event_id': eventId,
      'ticket_items': ticketItems.map((e) => e.toJson()).toList(),
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'customer_birth_date': customerBirthDate,
    };

    // Log request body
    developer.log('Checkout Request Body: $reqBody');

    final res = await ApiClient.post('/checkout', body: reqBody);

    // Log raw response
    developer.log('Checkout Response: $res');

    try {
      return CheckoutResultModel.fromJson(res['data']);
    } catch (e, stackTrace) {
      developer.log(
        'CheckoutResultModel.fromJson parsing error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

import '../models/ticket_model.dart';
import '../models/ticket_detail_model.dart';
import 'api_client.dart';

class TicketService {
  /// GET /my-tickets
  ///
  /// Mengembalikan tiket aktif (event belum selesai) dan riwayat (event sudah selesai).
  static Future<({List<TicketModel> active, List<TicketModel> history})>
  fetchMyTickets() async {
    final res = await ApiClient.get('/my-tickets');

    final data = res['data'] as Map<String, dynamic>? ?? {};

    final active = (data['active'] as List? ?? [])
        .map((e) => TicketModel.fromJson(e))
        .toList();

    final history = (data['history'] as List? ?? [])
        .map((e) => TicketModel.fromJson(e))
        .toList();

    return (active: active, history: history);
  }

  /// GET /my-tickets/{payment_id}
  ///
  /// Mengembalikan detail e-ticket termasuk QR codes.
  static Future<TicketDetailModel> fetchTicketDetail(String paymentId) async {
    final res = await ApiClient.get('/my-tickets/$paymentId');
    return TicketDetailModel.fromJson(res['data']);
  }
}

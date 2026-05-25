import '../models/scanner_stats_model.dart';
import 'api_client.dart';

class StaffService {
  /// GET /staff/dashboard?event_id=...
  ///
  /// Mengembalikan statistik scan tiket untuk event tertentu (realtime).
  static Future<ScannerStatsModel> fetchDashboard(String eventId) async {
    final res = await ApiClient.get(
      '/staff/dashboard',
      queryParams: {'event_id': eventId},
    );
    return ScannerStatsModel.fromJson(res['data']);
  }

  /// POST /staff/scan
  ///
  /// Scan QR code tiket oleh staff.
  /// Returns: type_name dan buyer_name jika sukses.
  static Future<({String typeName, String buyerName})> scanTicket({
    required String eventId,
    required String qrCodeString,
  }) async {
    final res = await ApiClient.post(
      '/staff/scan',
      body: {'event_id': eventId, 'qr_code_string': qrCodeString},
    );

    final data = res['data'] as Map<String, dynamic>? ?? {};
    return (
      typeName: data['type_name'] as String? ?? '',
      buyerName: data['buyer_name'] as String? ?? 'Pengunjung',
    );
  }
}

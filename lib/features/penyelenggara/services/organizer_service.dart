import '../../pemesan/services/api_client.dart';
import '../models/organizer_dashboard_model.dart';

class OrganizerService {
  /// GET /organizer/dashboard
  static Future<OrganizerDashboardModel> fetchDashboard() async {
    final res = await ApiClient.get('/organizer/dashboard');
    return OrganizerDashboardModel.fromJson(res['data'] ?? {});
  }

  /// GET /organizer/events/active
  static Future<List<Map<String, dynamic>>> fetchActiveEvents() async {
    final res = await ApiClient.get('/organizer/events/active');
    final dynamic data = res['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }

  /// POST /organizer/scan
  ///
  /// Validasi scan ticket untuk organizer.
  static Future<Map<String, dynamic>> scanTicket({
    required String eventId,
    required String qrCodeString,
    required String eventId,
  }) async {
    final res = await ApiClient.post(
      '/organizer/scan',
      body: {'qr_code_string': qrCodeString, 'event_id': eventId},
    );
    return res['data'] as Map<String, dynamic>? ?? {};
  }
}

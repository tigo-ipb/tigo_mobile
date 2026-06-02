import '../../pemesan/services/api_client.dart';
import '../models/organizer_dashboard_model.dart';

class OrganizerService {
  /// GET /organizer/dashboard
  static Future<OrganizerDashboardModel> fetchDashboard() async {
    final res = await ApiClient.get('/organizer/dashboard');
    return OrganizerDashboardModel.fromJson(res['data'] ?? {});
  }

  /// POST /organizer/scan
  ///
  /// Validasi scan ticket untuk organizer.
  static Future<Map<String, dynamic>> scanTicket({
    required String eventId,
    required String qrCodeString,
  }) async {
    final res = await ApiClient.post(
      '/organizer/scan',
      body: {
        'event_id': eventId,
        'qr_code_string': qrCodeString,
      },
    );
    return res['data'] as Map<String, dynamic>? ?? {};
  }
}

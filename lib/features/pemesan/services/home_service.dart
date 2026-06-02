import '../models/event_model.dart';
import 'api_client.dart';

class HomeService {
  /// GET /home?category=...
  ///
  /// Mengembalikan featured_events dan other_events.
  /// [category] opsional — jika diisi, filter berdasarkan kategori.
  static Future<({List<EventModel> featured, List<EventModel> others})>
  fetchHome({String? category}) async {
    final params = <String, String>{};
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }

    final res = await ApiClient.get(
      '/home',
      queryParams: params.isNotEmpty ? params : null,
      withAuth:
          true, // Endpoint publik, tapi jika user login, backend akan personalisasi
    );

    final data = res['data'] as Map<String, dynamic>? ?? {};

    final featured = (data['featured_events'] as List? ?? [])
        .map((e) => EventModel.fromJson(e))
        .toList();

    final others = (data['other_events'] as List? ?? [])
        .map((e) => EventModel.fromJson(e))
        .toList();

    return (featured: featured, others: others);
  }
}

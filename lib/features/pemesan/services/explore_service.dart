import '../models/event_model.dart';
import 'api_client.dart';

class ExplorePaginatedResult {
  final List<EventModel> events;
  final int currentPage;
  final int lastPage;
  final bool hasMore;

  ExplorePaginatedResult({
    required this.events,
    required this.currentPage,
    required this.lastPage,
    required this.hasMore,
  });
}

class ExploreService {
  /// GET /explore
  ///
  /// Filter params (semua opsional):
  /// - [name]      : pencarian nama event
  /// - [category]  : nama kategori (misal 'Edukasi')
  /// - [address]   : filter lokasi
  /// - [startDate] : format YYYY-MM-DD
  /// - [endDate]   : format YYYY-MM-DD
  /// - [priceMin]  : harga minimum
  /// - [priceMax]  : harga maksimum
  /// - [format]    : 'online' atau 'offline'
  /// - [page]      : halaman paginasi (default 1)
  static Future<ExplorePaginatedResult> fetchExplore({
    String? name,
    String? category,
    String? address,
    String? startDate,
    String? endDate,
    int? priceMin,
    int? priceMax,
    String? format,
    int page = 1,
  }) async {
    final params = <String, String>{'page': page.toString()};

    if (name != null && name.isNotEmpty) params['name'] = name;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (address != null && address.isNotEmpty) params['address'] = address;
    if (startDate != null && startDate.isNotEmpty) {
      params['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) params['end_date'] = endDate;
    if (priceMin != null) params['price_min'] = priceMin.toString();
    if (priceMax != null) params['price_max'] = priceMax.toString();
    if (format != null && format.isNotEmpty) params['format'] = format;

    final res = await ApiClient.get(
      '/explore',
      queryParams: params,
      withAuth: false,
    );

    // Laravel paginate() mengembalikan data di res['data'] yang berisi
    // { data: [...], current_page, last_page, ... }
    final paginatedData = res['data'] as Map<String, dynamic>? ?? {};
    final items = paginatedData['data'] as List? ?? [];

    final currentPage = (paginatedData['current_page'] ?? 1) is int
        ? paginatedData['current_page'] as int
        : (paginatedData['current_page'] as num).toInt();

    final lastPage = (paginatedData['last_page'] ?? 1) is int
        ? paginatedData['last_page'] as int
        : (paginatedData['last_page'] as num).toInt();

    return ExplorePaginatedResult(
      events: items.map((e) => EventModel.fromJson(e)).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      hasMore: currentPage < lastPage,
    );
  }
}

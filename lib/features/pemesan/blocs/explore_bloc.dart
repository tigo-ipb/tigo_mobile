import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/explore_service.dart';
import '../services/api_client.dart';

enum ExploreStatus { idle, loading, loaded, loadingMore, error }

class ExploreBloc extends ChangeNotifier {
  ExploreStatus _status = ExploreStatus.idle;
  List<EventModel> _events = [];
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = false;

  // Active filter params (agar loadNextPage bisa pakai filter yang sama)
  String? _name;
  String? _category;
  String? _address;
  String? _startDate;
  String? _endDate;
  int? _priceMin;
  int? _priceMax;
  String? _format;

  ExploreStatus get status => _status;
  List<EventModel> get events => _events;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isLoading => _status == ExploreStatus.loading;
  bool get isLoadingMore => _status == ExploreStatus.loadingMore;

  /// Ambil data pertama (page 1) dengan filter yang diberikan.
  Future<void> fetchExplore({
    String? name,
    String? category,
    String? address,
    String? startDate,
    String? endDate,
    int? priceMin,
    int? priceMax,
    String? format,
  }) async {
    // Simpan filter aktif
    _name = name;
    _category = category;
    _address = address;
    _startDate = startDate;
    _endDate = endDate;
    _priceMin = priceMin;
    _priceMax = priceMax;
    _format = format;

    _status = ExploreStatus.loading;
    _errorMessage = null;
    _events = [];
    _currentPage = 1;
    notifyListeners();

    try {
      final result = await ExploreService.fetchExplore(
        name: _name,
        category: _category,
        address: _address,
        startDate: _startDate,
        endDate: _endDate,
        priceMin: _priceMin,
        priceMax: _priceMax,
        format: _format,
        page: 1,
      );

      _events = result.events;
      _currentPage = result.currentPage;
      _hasMore = result.hasMore;
      _status = ExploreStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ExploreStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = ExploreStatus.error;
    }

    notifyListeners();
  }

  /// Muat halaman berikutnya (infinite scroll).
  Future<void> loadNextPage() async {
    if (!_hasMore || _status == ExploreStatus.loadingMore) return;

    _status = ExploreStatus.loadingMore;
    notifyListeners();

    try {
      final result = await ExploreService.fetchExplore(
        name: _name,
        category: _category,
        address: _address,
        startDate: _startDate,
        endDate: _endDate,
        priceMin: _priceMin,
        priceMax: _priceMax,
        format: _format,
        page: _currentPage + 1,
      );

      _events.addAll(result.events);
      _currentPage = result.currentPage;
      _hasMore = result.hasMore;
      _status = ExploreStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ExploreStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = ExploreStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = ExploreStatus.idle;
    _events = [];
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = false;
    notifyListeners();
  }
}

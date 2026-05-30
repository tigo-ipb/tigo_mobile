import 'package:flutter/foundation.dart';
import '../models/event_detail_model.dart';
import '../services/explore_service.dart';
import '../services/api_client.dart';

enum EventDetailStatus { idle, loading, loaded, error }

class EventDetailBloc extends ChangeNotifier {
  EventDetailStatus _status = EventDetailStatus.idle;
  EventDetailModel? _eventDetail;
  String? _errorMessage;

  EventDetailStatus get status => _status;
  EventDetailModel? get eventDetail => _eventDetail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == EventDetailStatus.loading;
  bool get isLoaded => _status == EventDetailStatus.loaded;

  Future<void> fetchEventDetail(String id) async {
    _status = EventDetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventDetail = await ExploreService.fetchEventDetails(id);
      _status = EventDetailStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = EventDetailStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = EventDetailStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = EventDetailStatus.idle;
    _eventDetail = null;
    _errorMessage = null;
    notifyListeners();
  }
}

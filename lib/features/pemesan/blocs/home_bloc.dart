import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/home_service.dart';
import '../services/api_client.dart';

enum HomeStatus { idle, loading, loaded, error }

class HomeBloc extends ChangeNotifier {
  HomeStatus _status = HomeStatus.idle;
  List<EventModel> _featuredEvents = [];
  List<EventModel> _otherEvents = [];
  String? _errorMessage;

  HomeStatus get status => _status;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<EventModel> get otherEvents => _otherEvents;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == HomeStatus.loading;

  Future<void> fetchHome({String? category}) async {
    _status = HomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await HomeService.fetchHome(category: category);
      _featuredEvents = result.featured;
      _otherEvents = result.others;
      _status = HomeStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = HomeStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = HomeStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = HomeStatus.idle;
    _errorMessage = null;
    _featuredEvents = [];
    _otherEvents = [];
    notifyListeners();
  }
}

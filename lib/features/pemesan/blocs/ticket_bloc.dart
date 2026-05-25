import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../models/ticket_detail_model.dart';
import '../services/ticket_service.dart';
import '../services/api_client.dart';

enum TicketStatus { idle, loading, loaded, error }

class TicketBloc extends ChangeNotifier {
  TicketStatus _status = TicketStatus.idle;
  List<TicketModel> _activeTickets = [];
  List<TicketModel> _historyTickets = [];
  TicketDetailModel? _currentDetail;
  String? _errorMessage;

  TicketStatus get status => _status;
  List<TicketModel> get activeTickets => _activeTickets;
  List<TicketModel> get historyTickets => _historyTickets;
  TicketDetailModel? get currentDetail => _currentDetail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TicketStatus.loading;

  Future<void> fetchMyTickets() async {
    _status = TicketStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await TicketService.fetchMyTickets();
      _activeTickets = result.active;
      _historyTickets = result.history;
      _status = TicketStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = TicketStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = TicketStatus.error;
    }

    notifyListeners();
  }

  Future<void> fetchTicketDetail(String paymentId) async {
    _status = TicketStatus.loading;
    _currentDetail = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentDetail = await TicketService.fetchTicketDetail(paymentId);
      _status = TicketStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = TicketStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = TicketStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = TicketStatus.idle;
    _activeTickets = [];
    _historyTickets = [];
    _currentDetail = null;
    _errorMessage = null;
    notifyListeners();
  }
}

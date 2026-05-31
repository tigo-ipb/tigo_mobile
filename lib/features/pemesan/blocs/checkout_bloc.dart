import 'package:flutter/foundation.dart';
import '../models/checkout_model.dart';
import '../services/checkout_service.dart';
import '../services/api_client.dart';

export '../services/checkout_service.dart' show TicketOrderItem;

enum CheckoutStatus { idle, loading, success, error }

class CheckoutBloc extends ChangeNotifier {
  CheckoutStatus _status = CheckoutStatus.idle;
  CheckoutResultModel? _result;
  String? _errorMessage;

  CheckoutStatus get status => _status;
  CheckoutResultModel? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == CheckoutStatus.loading;
  bool get isSuccess => _status == CheckoutStatus.success;

  Future<bool> checkout({
    required String eventId,
    required List<TicketOrderItem> ticketItems,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerBirthDate,
  }) async {
    _status = CheckoutStatus.loading;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      _result = await CheckoutService.checkout(
        eventId: eventId,
        ticketItems: ticketItems,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        customerBirthDate: customerBirthDate,
      );
      _status = CheckoutStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CheckoutStatus.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = CheckoutStatus.idle;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}

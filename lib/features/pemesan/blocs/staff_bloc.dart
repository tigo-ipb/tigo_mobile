import 'package:flutter/foundation.dart';
import '../models/scanner_stats_model.dart';
import '../services/staff_service.dart';
import '../services/api_client.dart';

enum StaffStatus {
  idle,
  loading,
  loaded,
  scanning,
  scanSuccess,
  scanError,
  error,
}

class StaffBloc extends ChangeNotifier {
  StaffStatus _status = StaffStatus.idle;
  ScannerStatsModel? _stats;
  String? _errorMessage;
  String? _lastScannedTypeName;
  String? _lastScannedBuyerName;

  StaffStatus get status => _status;
  ScannerStatsModel? get stats => _stats;
  String? get errorMessage => _errorMessage;
  String? get lastScannedTypeName => _lastScannedTypeName;
  String? get lastScannedBuyerName => _lastScannedBuyerName;
  bool get isLoading => _status == StaffStatus.loading;
  bool get isScanning => _status == StaffStatus.scanning;

  Future<void> fetchDashboard(String eventId) async {
    _status = StaffStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _stats = await StaffService.fetchDashboard(eventId);
      _status = StaffStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = StaffStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = StaffStatus.error;
    }

    notifyListeners();
  }

  Future<bool> scanTicket({
    required String eventId,
    required String qrCodeString,
  }) async {
    _status = StaffStatus.scanning;
    _errorMessage = null;
    _lastScannedTypeName = null;
    _lastScannedBuyerName = null;
    notifyListeners();

    try {
      final result = await StaffService.scanTicket(
        eventId: eventId,
        qrCodeString: qrCodeString,
      );
      _lastScannedTypeName = result.typeName;
      _lastScannedBuyerName = result.buyerName;
      _status = StaffStatus.scanSuccess;
      notifyListeners();

      // Auto-refresh dashboard setelah scan sukses
      fetchDashboard(eventId);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = StaffStatus.scanError;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = StaffStatus.idle;
    _stats = null;
    _errorMessage = null;
    _lastScannedTypeName = null;
    _lastScannedBuyerName = null;
    notifyListeners();
  }
}

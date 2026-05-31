import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

enum AuthStatus { idle, loading, success, error, needsSetup }

class AuthBloc extends ChangeNotifier {
  AuthStatus _status = AuthStatus.idle;
  UserModel? _user;
  String? _errorMessage;
  String? _pendingEmail; // Dipakai saat menunggu OTP

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get pendingEmail => _pendingEmail;
  bool get isLoading => _status == AuthStatus.loading;

  // ---------------------------------------------------------------------------
  // Inisialisasi — cek apakah sudah login (token ada)
  // ---------------------------------------------------------------------------
  Future<bool> checkLoginStatus() async {
    return AuthService.isLoggedIn();
  }

  // ---------------------------------------------------------------------------
  // Register
  // ---------------------------------------------------------------------------
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final registeredEmail = await AuthService.register(
        username: username,
        email: email,
        password: password,
      );
      _pendingEmail = registeredEmail;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Verify Email (OTP)
  // ---------------------------------------------------------------------------
  Future<bool> verifyEmail({required String email, required String otp}) async {
    _setLoading();
    try {
      final result = await AuthService.verifyEmail(email: email, otp: otp);
      _user = result.user;
      _status = result.needsSetup ? AuthStatus.needsSetup : AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------
  Future<bool> login({required String login, required String password}) async {
    _setLoading();
    try {
      final result = await AuthService.login(login: login, password: password);
      _user = result.user;
      _status = result.needsSetup ? AuthStatus.needsSetup : AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Google Login
  // ---------------------------------------------------------------------------
  Future<bool> googleLogin({required String idToken}) async {
    _setLoading();
    try {
      final result = await AuthService.googleLogin(idToken: idToken);
      _user = result.user;
      _status = result.needsSetup ? AuthStatus.needsSetup : AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot Password
  // ---------------------------------------------------------------------------
  Future<bool> forgotPassword({required String login}) async {
    _setLoading();
    try {
      await AuthService.forgotPassword(login: login);
      _pendingEmail = login;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Reset Password
  // ---------------------------------------------------------------------------
  Future<bool> resetPassword({
    required String login,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading();
    try {
      await AuthService.resetPassword(
        login: login,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Setup Profile
  // ---------------------------------------------------------------------------
  Future<bool> setupProfile({
    required String phoneNumber,
    required String birthDate,
    String? name,
    String? username,
    String? bio,
    String? phoneCode,
    XFile? profilePhoto,
  }) async {
    _setLoading();
    try {
      final updatedUser = await AuthService.setupProfile(
        phoneNumber: phoneNumber,
        birthDate: birthDate,
        name: name,
        username: username,
        bio: bio,
        phoneCode: phoneCode,
        profilePhoto: profilePhoto,
      );
      _user = updatedUser;
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Reset state (misal kembali ke halaman sebelumnya)
  // ---------------------------------------------------------------------------
  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
}

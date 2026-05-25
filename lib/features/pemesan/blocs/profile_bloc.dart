import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/profile_service.dart';
import '../services/api_client.dart';

enum ProfileStatus { idle, loading, loaded, updating, error }

class ProfileBloc extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.idle;
  UserModel? _user;
  String? _errorMessage;
  bool _updateSuccess = false;

  ProfileStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isUpdating => _status == ProfileStatus.updating;
  bool get updateSuccess => _updateSuccess;

  Future<void> fetchProfile() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await ProfileService.fetchProfile();
      _status = ProfileStatus.loaded;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ProfileStatus.error;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga.';
      _status = ProfileStatus.error;
    }

    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? birthDate,
    String? phoneCode,
    String? phoneNumber,
    File? profilePhoto,
  }) async {
    _status = ProfileStatus.updating;
    _updateSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await ProfileService.updateProfile(
        name: name,
        username: username,
        bio: bio,
        birthDate: birthDate,
        phoneCode: phoneCode,
        phoneNumber: phoneNumber,
        profilePhoto: profilePhoto,
      );
      _status = ProfileStatus.loaded;
      _updateSuccess = true;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _status = ProfileStatus.updating;
    _updateSuccess = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await ProfileService.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _status = ProfileStatus.loaded;
      _updateSuccess = true;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = ProfileStatus.idle;
    _user = null;
    _errorMessage = null;
    _updateSuccess = false;
    notifyListeners();
  }
}

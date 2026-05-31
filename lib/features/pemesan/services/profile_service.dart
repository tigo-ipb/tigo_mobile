import 'dart:io';
import '../models/user_model.dart';
import 'api_client.dart';

class ProfileService {
  /// GET /profile
  static Future<UserModel> fetchProfile() async {
    final res = await ApiClient.get('/profile');
    return UserModel.fromJson(res['data']);
  }

  /// POST /profile/update-profile (multipart — mendukung upload foto profil)
  static Future<UserModel> updateProfile({
    String? username,
    String? bio,
    File? profilePhoto,
  }) async {
    final fields = <String, String>{};
    if (username != null) fields['username'] = username;
    if (bio != null) fields['bio'] = bio;

    final res = await ApiClient.postMultipart(
      '/profile/update-profile',
      fields: fields,
      file: profilePhoto,
    );

    return UserModel.fromJson(res['data']);
  }

  /// PUT /profile/update-account
  static Future<UserModel> updateAccount({
    required String name,
    required String email,
    required String birthDate,
    required String phoneCode,
    required String phoneNumber,
  }) async {
    final res = await ApiClient.put(
      '/profile/update-account',
      body: {
        'name': name,
        'email': email,
        'birth_date': birthDate,
        'phone_code': phoneCode,
        'phone_number': phoneNumber,
      },
    );
    return UserModel.fromJson(res['data']);
  }

  /// PUT /profile/password
  static Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await ApiClient.put(
      '/profile/password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );
  }
}

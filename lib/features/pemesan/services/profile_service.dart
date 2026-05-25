import 'dart:io';
import '../models/user_model.dart';
import 'api_client.dart';

class ProfileService {
  /// GET /profile
  static Future<UserModel> fetchProfile() async {
    final res = await ApiClient.get('/profile');
    return UserModel.fromJson(res['data']);
  }

  /// POST /profile/update (multipart — mendukung upload foto profil)
  static Future<UserModel> updateProfile({
    String? name,
    String? username,
    String? bio,
    String? birthDate,
    String? phoneCode,
    String? phoneNumber,
    File? profilePhoto,
  }) async {
    final fields = <String, String>{};
    if (name != null) fields['name'] = name;
    if (username != null) fields['username'] = username;
    if (bio != null) fields['bio'] = bio;
    if (birthDate != null) fields['birth_date'] = birthDate;
    if (phoneCode != null) fields['phone_code'] = phoneCode;
    if (phoneNumber != null) fields['phone_number'] = phoneNumber;

    final res = await ApiClient.postMultipart(
      '/profile/update',
      fields: fields,
      file: profilePhoto,
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

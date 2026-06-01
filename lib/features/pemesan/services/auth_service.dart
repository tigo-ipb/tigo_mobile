import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  // ---------------------------------------------------------------------------
  // POST /auth/register
  // Returns email yang terdaftar (untuk diteruskan ke halaman OTP)
  // ---------------------------------------------------------------------------
  static Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.post(
      '/auth/register',
      body: {'username': username, 'email': email, 'password': password},
      withAuth: false,
    );
    return res['data']?['email'] ?? email;
  }

  // ---------------------------------------------------------------------------
  // POST /auth/verify-email
  // Verifikasi OTP register → auto login, kembalikan token + user
  // ---------------------------------------------------------------------------
  static Future<({UserModel user, String token, bool needsSetup})> verifyEmail({
    required String email,
    required String otp,
  }) async {
    final res = await ApiClient.post(
      '/auth/verify-email',
      body: {'email': email, 'otp': otp},
      withAuth: false,
    );

    final data = res['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;
    final needsSetup = data['needs_setup'] == true;

    await ApiClient.saveToken(token);
    await ApiClient.saveRole(user.role);

    return (user: user, token: token, needsSetup: needsSetup);
  }

  // ---------------------------------------------------------------------------
  // POST /auth/login
  // ---------------------------------------------------------------------------
  static Future<({UserModel user, String token, bool needsSetup})> login({
    required String login, // bisa email atau username
    required String password,
  }) async {
    final res = await ApiClient.post(
      '/auth/login',
      body: {'login': login, 'password': password},
      withAuth: false,
    );

    final data = res['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;
    final needsSetup = data['needs_setup'] == true;

    await ApiClient.saveToken(token);
    await ApiClient.saveRole(user.role);

    return (user: user, token: token, needsSetup: needsSetup);
  }

  // ---------------------------------------------------------------------------
  // POST /auth/google
  // Login via Google (kirim id_token dari Google Sign-In SDK)
  // ---------------------------------------------------------------------------
  static Future<({UserModel user, String token, bool needsSetup})> googleLogin({
    required String idToken,
  }) async {
    final res = await ApiClient.post(
      '/auth/google',
      body: {'id_token': idToken},
      withAuth: false,
    );

    final data = res['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user']);
    final token = data['token'] as String;
    final needsSetup = data['needs_setup'] == true;

    await ApiClient.saveToken(token);
    await ApiClient.saveRole(user.role);

    return (user: user, token: token, needsSetup: needsSetup);
  }

  // ---------------------------------------------------------------------------
  // POST /auth/resend-otp
  // ---------------------------------------------------------------------------
  static Future<void> resendOtp({required String email}) async {
    await ApiClient.post(
      '/auth/resend-otp',
      body: {'email': email},
      withAuth: false,
    );
  }

  // ---------------------------------------------------------------------------
  // POST /auth/forgot-password
  // ---------------------------------------------------------------------------
  static Future<void> forgotPassword({required String login}) async {
    await ApiClient.post(
      '/auth/forgot-password',
      body: {'login': login},
      withAuth: false,
    );
  }

  // ---------------------------------------------------------------------------
  // POST /auth/reset-password
  // ---------------------------------------------------------------------------
  static Future<void> resetPassword({
    required String login,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    await ApiClient.post(
      '/auth/reset-password',
      body: {
        'login': login,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      withAuth: false,
    );
  }

  // ---------------------------------------------------------------------------
  // POST /auth/setup-profile (protected)
  // ---------------------------------------------------------------------------
  static Future<UserModel> setupProfile({
    required String phoneNumber,
    required String birthDate,
    String? name,
    String? username,
    String? bio,
    String? phoneCode,
    XFile? profilePhoto,
  }) async {
    final fields = Map.fromEntries(<MapEntry<String, String>>[
      MapEntry('phone_number', phoneNumber),
      MapEntry('birth_date', birthDate),
      if (name != null) MapEntry('name', name),
      if (username != null) MapEntry('username', username),
      if (bio != null) MapEntry('bio', bio),
      if (phoneCode != null) MapEntry('phone_code', phoneCode),
    ]);

    final res = await ApiClient.postMultipart(
      '/auth/setup-profile',
      fields: fields,
      file: profilePhoto,
    );

    return UserModel.fromJson(res['data']);
  }

  // ---------------------------------------------------------------------------
  // LOGOUT — hanya hapus token lokal
  // ---------------------------------------------------------------------------
  static Future<void> logout() async {
    await ApiClient.clearToken();
  }

  // ---------------------------------------------------------------------------
  // Cek apakah user sudah login (token tersimpan)
  // ---------------------------------------------------------------------------
  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getToken();
    return token != null;
  }
}

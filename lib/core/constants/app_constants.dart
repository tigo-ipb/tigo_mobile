class AppConstants {
  // ===========================================================================
  // BASE URL
  // ===========================================================================
  static const String baseUrl = 'https://tigo-ipb.up.railway.app/api';

  // ===========================================================================
  // SECURE STORAGE KEYS
  // ===========================================================================
  static const String tokenKey = 'auth_token';
  static const String userRoleKey = 'user_role';

  // ===========================================================================
  // IMAGE RESOLUTION HELPERS
  // ===========================================================================
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;

    final cleanPath = path.startsWith('/') ? path : '/$path';
    final base = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$base$cleanPath';
  }

  // ===========================================================================
  // GOOGLE SIGN IN CLIENT ID (FOR WEB)
  // ===========================================================================
  static const String googleClientId =
      '215018091868-ao9di7709r6grl6nv1ganlmqa9jgenas.apps.googleusercontent.com';
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Sky (Blue)
  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky100 = Color(0xFFDFF2FE);
  static const Color sky200 = Color(0xFFB8E6FE);
  static const Color sky300 = Color(0xFF74D4FF);
  static const Color sky400 = Color(0xFF00BCFF);
  static const Color sky500 = Color(0xFF00A6F4);
  static const Color sky600 = Color(0xFF0084D1);
  static const Color sky700 = Color(0xFF0069A8);
  static const Color sky800 = Color(0xFF00598A);
  static const Color sky900 = Color(0xFF024A70);
  static const Color sky950 = Color(0xFF052F4A);

  // Neutral (Monochrome)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA1A1A1);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);

  // Red
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFFE2E2);
  static const Color red200 = Color(0xFFFFC9C9);
  static const Color red300 = Color(0xFFFFA2A2);
  static const Color red400 = Color(0xFFFF6467);
  static const Color red500 = Color(0xFFFB2C36);
  static const Color red600 = Color(0xFFE7000B);
  static const Color red700 = Color(0xFFC10007);
  static const Color red800 = Color(0xFF9F0712);
  static const Color red900 = Color(0xFF82181A);
  static const Color red950 = Color(0xFF460809);

  // Yellow
  static const Color yellow50 = Color(0xFFFEFCE8);
  static const Color yellow100 = Color(0xFFFEF9C2);
  static const Color yellow200 = Color(0xFFFFF085);
  static const Color yellow300 = Color(0xFFFFDF20);
  static const Color yellow400 = Color(0xFFFCC800);
  static const Color yellow500 = Color(0xFFEFB100);
  static const Color yellow600 = Color(0xFFD08700);
  static const Color yellow700 = Color(0xFFA65F00);
  static const Color yellow800 = Color(0xFF894B00);
  static const Color yellow900 = Color(0xFF733E0A);
  static const Color yellow950 = Color(0xFF432004);

  // Green
  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green200 = Color(0xFFB9F8CF);
  static const Color green300 = Color(0xFF7BF1A8);
  static const Color green400 = Color(0xFF05DF72);
  static const Color green500 = Color(0xFF00C951);
  static const Color green600 = Color(0xFF00A63E);
  static const Color green700 = Color(0xFF008236);
  static const Color green800 = Color(0xFF016630);
  static const Color green900 = Color(0xFF0D542B);
  static const Color green950 = Color(0xFF032E15);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sky500,
        primary: AppColors.sky500,
        surface: Colors.white,
        error: AppColors.red500,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(),
    );
  }
}

class AppTextStyles {
  static TextStyle get poppins => GoogleFonts.poppins();

  // Thin (100)
  static TextStyle thin(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w100,
    color: color,
  );

  // Extra Light (200)
  static TextStyle extraLight(double size, [Color? color]) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w200,
        color: color,
      );

  // Light (300)
  static TextStyle light(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w300,
    color: color,
  );

  // Regular (400)
  static TextStyle regular(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w400,
    color: color,
  );

  // Medium (500)
  static TextStyle medium(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // Semi Bold (600)
  static TextStyle semiBold(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
  );

  // Bold (700)
  static TextStyle bold(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color,
  );

  // Extra Bold (800)
  static TextStyle extraBold(double size, [Color? color]) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
      );

  // Black (900)
  static TextStyle black(double size, [Color? color]) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: FontWeight.w900,
    color: color,
  );
}

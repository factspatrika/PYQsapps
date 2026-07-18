import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF041626);
  static const Color secondaryColor = Color(0xFF735C00);
  static const Color tertiaryColor = Color(0xFF131617);
  static const Color backgroundColor = Color(0xFFF9F9FF);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF111C2C);
  static const Color subtitleColor = Color(0xFF43474C);
  static const Color successColor = Color(0xFF48BB78);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color warningColor = Color(0xFFFED65B);

  static const Color darkBackgroundColor = Color(0xFF0D1117);
  static const Color darkCardColor = Color(0xFF1C2128);
  static const Color darkElevatedCardColor = Color(0xFF21262D);
  static const Color darkTextColor = Color(0xFFF0F6FC);
  static const Color darkSubtitleColor = Color(0xFF8B949E);
  static const Color darkPrimaryColor = Color(0xFFFED65B);
  static const Color darkBorderColor = Color(0xFF30363D);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Be Vietnam Pro',
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        onSurface: textColor,
        onSurfaceVariant: subtitleColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontFamily: 'Be Vietnam Pro',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFC4C6CC), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: primaryColor, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: primaryColor, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textColor, fontFamily: 'Be Vietnam Pro'),
        bodyMedium: TextStyle(color: subtitleColor, fontFamily: 'Be Vietnam Pro'),
        labelSmall: TextStyle(color: textColor, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC4C6CC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC4C6CC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: subtitleColor, fontFamily: 'Be Vietnam Pro'),
        hintStyle: const TextStyle(color: subtitleColor, fontFamily: 'Be Vietnam Pro'),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFFC4C6CC), thickness: 1),
      iconTheme: const IconThemeData(color: primaryColor),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Be Vietnam Pro'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      fontFamily: 'Be Vietnam Pro',
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: Color(0xFFFED65B),
        surface: darkCardColor,
        onSurface: darkTextColor,
        onSurfaceVariant: darkSubtitleColor,
        error: Color(0xFFF85149),
        outline: darkBorderColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkTextColor),
        titleTextStyle: TextStyle(
          color: darkTextColor,
          fontFamily: 'Be Vietnam Pro',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorderColor, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(color: darkTextColor, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: darkTextColor, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextColor, fontFamily: 'Be Vietnam Pro'),
        bodyMedium: TextStyle(color: darkSubtitleColor, fontFamily: 'Be Vietnam Pro'),
        labelSmall: TextStyle(color: darkTextColor, fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: darkBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryColor,
          side: const BorderSide(color: darkPrimaryColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Be Vietnam Pro', fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevatedCardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkPrimaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF85149)),
        ),
        labelStyle: const TextStyle(color: darkSubtitleColor, fontFamily: 'Be Vietnam Pro'),
        hintStyle: const TextStyle(color: darkSubtitleColor, fontFamily: 'Be Vietnam Pro'),
      ),
      dividerTheme: const DividerThemeData(color: darkBorderColor, thickness: 1),
      iconTheme: const IconThemeData(color: darkTextColor),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkElevatedCardColor,
        contentTextStyle: const TextStyle(color: darkTextColor, fontFamily: 'Be Vietnam Pro'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(color: darkTextColor, fontFamily: 'Be Vietnam Pro', fontSize: 20, fontWeight: FontWeight.bold),
        contentTextStyle: const TextStyle(color: darkSubtitleColor, fontFamily: 'Be Vietnam Pro', fontSize: 15),
      ),
    );
  }
}
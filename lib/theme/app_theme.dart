import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryGreen = Color(0xFF00FF57);
  static const Color primaryGreenDark = Color(0xFF00CC45);
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkCard = Color(0xFF181A20);
  
  // الوضع المظلم
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: _createMaterialColor(primaryGreen),
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      
      // نظام الألوان
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryGreenDark,
        surface: darkSurface,
        background: darkBackground,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        error: Colors.red,
        onError: Colors.white,
      ),
      
      // شريط التطبيق
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // البطاقات
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // الأزرار المرفوعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // الأزرار المحددة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // حقول النص
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      
      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
      ),
      
      // النصوص
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white70),
        labelLarge: TextStyle(color: Colors.white),
        labelMedium: TextStyle(color: Colors.white),
        labelSmall: TextStyle(color: Colors.white70),
      ),
    );
  }
  
  // الوضع الفاتح
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: _createMaterialColor(primaryGreen),
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: Colors.grey[50],
      cardColor: Colors.white,
      
      // نظام الألوان
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: primaryGreenDark,
        surface: Colors.white,
        background: Colors.grey[50]!,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        error: Colors.red,
        onError: Colors.white,
      ),
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // البطاقات
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // الأزرار المرفوعة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // الأزرار المحددة
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      
      // حقول النص
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey[700]),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      
      // شريط التنقل السفلي
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // النصوص
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.grey[800]),
        bodyMedium: TextStyle(color: Colors.grey[800]),
        bodySmall: TextStyle(color: Colors.grey[600]),
        labelLarge: TextStyle(color: Colors.grey[800]),
        labelMedium: TextStyle(color: Colors.grey[800]),
        labelSmall: TextStyle(color: Colors.grey[600]),
      ),
    );
  }
  
  // إنشاء MaterialColor من Color
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
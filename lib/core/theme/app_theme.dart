import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AcePick 앱의 통일된 테마를 정의하는 파일
///
/// 색상, 텍스트 스타일, 컴포넌트 테마 등을 정의합니다.

// ============================================================================
// 색상 정의
// ============================================================================

/// 앱의 주요 색상들을 정의하는 클래스
class AppColors {
  // 기본 색상
  static const Color primary = Color(0xFF1976D2);      // Blue 700
  static const Color secondary = Color(0xFFF57C00);    // Orange 600
  static const Color background = Color(0xFFF5F5F5);   // Grey 100
  
  // 상태 색상
  static const Color success = Color(0xFF4CAF50);      // Green
  static const Color error = Color(0xFFF44336);        // Red
  static const Color warning = Color(0xFFFFC107);      // Amber
  static const Color info = Color(0xFF2196F3);         // Blue
  
  // 텍스트 색상
  static const Color textPrimary = Color(0xFF212121);  // Dark Grey
  static const Color textSecondary = Color(0xFF757575); // Medium Grey
  static const Color textHint = Color(0xFFBDBDBD);     // Light Grey
  
  // 배경 색상
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFFFAFAFA);  // Almost White
  
  // 테두리 색상
  static const Color divider = Color(0xFFE0E0E0);      // Light Grey
}

// ============================================================================
// 텍스트 스타일 정의
// ============================================================================

/// 앱의 텍스트 스타일들을 정의하는 클래스
class AppTextStyles {
  // Headline 스타일
  static TextStyle headline1 = GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle headline2 = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle headline3 = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Body 스타일
  static TextStyle bodyText1 = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyText2 = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // Caption 스타일
  static TextStyle caption = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // Button 스타일
  static TextStyle button = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

// ============================================================================
// 테마 생성 함수
// ============================================================================

/// AcePick 앱의 ThemeData를 반환합니다
///
/// 색상, 텍스트 스타일, 컴포넌트 테마 등이 적용된 통일된 테마를 제공합니다.
///
/// 반환: 앱에 적용할 ThemeData
ThemeData getAppTheme() {
  return ThemeData(
    // ========================================================================
    // 기본 색상 설정
    // ========================================================================
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    dividerColor: AppColors.divider,
    
    // ========================================================================
    // ColorScheme 설정 (Material 3)
    // ========================================================================
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      brightness: Brightness.light,
    ),
    
    // ========================================================================
    // TextTheme 설정
    // ========================================================================
    textTheme: TextTheme(
      displayLarge: AppTextStyles.headline1,
      displayMedium: AppTextStyles.headline2,
      displaySmall: AppTextStyles.headline3,
      headlineMedium: AppTextStyles.headline2,
      headlineSmall: AppTextStyles.headline3,
      titleLarge: AppTextStyles.headline3,
      titleMedium: AppTextStyles.bodyText1,
      titleSmall: AppTextStyles.bodyText2,
      bodyLarge: AppTextStyles.bodyText1,
      bodyMedium: AppTextStyles.bodyText2,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.caption,
      labelSmall: AppTextStyles.caption,
    ),
    
    // ========================================================================
    // AppBarTheme 설정
    // ========================================================================
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    // ========================================================================
    // CardTheme 설정
    // ========================================================================
    cardTheme: CardTheme(
      color: AppColors.surfaceLight,
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // ========================================================================
    // ButtonTheme 설정
    // ========================================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.button,
        elevation: 2,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // ========================================================================
    // InputDecorationTheme 설정
    // ========================================================================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: AppTextStyles.bodyText2,
      hintStyle: GoogleFonts.roboto(
        fontSize: 14,
        color: AppColors.textHint,
      ),
      errorStyle: GoogleFonts.roboto(
        fontSize: 12,
        color: AppColors.error,
      ),
    ),
    
    // ========================================================================
    // ChipTheme 설정
    // ========================================================================
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: AppTextStyles.bodyText2,
      secondaryLabelStyle: GoogleFonts.roboto(
        fontSize: 14,
        color: Colors.white,
      ),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // ========================================================================
    // BottomNavigationBarTheme 설정
    // ========================================================================
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.roboto(
        fontSize: 12,
      ),
    ),
    
    // ========================================================================
    // FloatingActionButtonTheme 설정
    // ========================================================================
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      hoverElevation: 8,
      focusElevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // ========================================================================
    // ListTileTheme 설정
    // ========================================================================
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: AppColors.surfaceLight,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      textColor: AppColors.textPrimary,
      selectedColor: AppColors.primary,
    ),
    
    // ========================================================================
    // DialogTheme 설정
    // ========================================================================
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surfaceLight,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: AppTextStyles.headline2,
      contentTextStyle: AppTextStyles.bodyText1,
    ),
  );
}

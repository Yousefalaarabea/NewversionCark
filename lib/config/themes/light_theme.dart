import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';

// Light theme
ThemeData lightTheme = ThemeData(
  fontFamily: 'Inter',
  // Color scheme for light mode
  colorScheme: ColorScheme(
    // Light theme brightness
    brightness: Brightness.light,
    // Main color
    primary: AppColors.primary,
    // Text color on primary elements
    onPrimary: AppColors.white,
    onPrimaryFixed: AppColors.primary.withOpacity(0.2),
    // Secondary color
    secondary: AppColors.gray,
    // Text color on secondary
    onSecondary: AppColors.black,
    onSecondaryFixed: AppColors.black.withOpacity(0.5),
    onSecondaryContainer: Colors.grey.shade200 ,
    onSecondaryFixedVariant: Colors.grey.shade400,
    // Error color
    error: AppColors.red,
    // Text color on error background
    onError: AppColors.white,
    // Background for cards, sheets,
    surface: AppColors.white,
    // Text color on surfaces
    onSurface: AppColors.black,
    // onSurfaceVariant: AppColors.green,




  ),
  // Styling for all ElevatedButtons in the app
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(AppColors.primary),
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontWeight: FontWeight.w600,
          // Responsive font size
          fontSize: 20.sp,
          // Text color
          color: AppColors.white,
        ),
      ),
      shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>(
        (states) {
          if (states.contains(WidgetState.disabled)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            );
          } else {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            );
          }
        },
      ),
      fixedSize: WidgetStateProperty.all<Size>(
        const Size(double.infinity, 48),
      ),
    ),
  ),
  // Styling for all TextFields in the app
  inputDecorationTheme: InputDecorationTheme(
    // Fill color of the text field
    fillColor: AppColors.white,

    // Enables the fill color
    filled: true,

    // Style for hint text
    hintStyle: TextStyle(
      color: AppColors.lightBlack,
      fontWeight: FontWeight.w400,
      fontSize: 17,
    ),

    // Default border
    border: decorateBorder(AppColors.lightBlack),

    // When not focused
    enabledBorder: decorateBorder(AppColors.lightBlack),

    // When focused
    focusedBorder: decorateBorder(AppColors.lightBlack),

    // When error exists
    errorBorder: decorateBorder(AppColors.red),

    // Error text style
    errorStyle: const TextStyle(
      color: AppColors.red,
      fontWeight: FontWeight.w400,
      fontSize: 17,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.gray,
    backgroundColor: AppColors.white,
  ),
);

// Helper function to return a border with custom color
OutlineInputBorder decorateBorder(Color color) {
  return OutlineInputBorder(
    // Rounded corners for input field
    borderRadius: BorderRadius.circular(10),

    // Dynamic color for border
    borderSide: BorderSide(
      color: color,
    ),
  );
}

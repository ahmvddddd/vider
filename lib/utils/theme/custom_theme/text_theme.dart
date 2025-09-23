import 'package:flutter/material.dart';
import '../../helpers/responsive_size.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextTheme(BuildContext context) => TextTheme(
    headlineLarge: TextStyle(
          fontSize: responsiveText(context, 32.0),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: responsiveText(context, 24.0),
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        headlineSmall: TextStyle(
          fontSize: responsiveText(context, 18.0),
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        titleLarge: TextStyle(
          fontSize: responsiveText(context, 16.0),
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: responsiveText(context, 16.0),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        titleSmall: TextStyle(
          fontSize: responsiveText(context, 16.0),
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontSize: responsiveText(context, 14.0),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        bodyMedium: TextStyle(
          fontSize: responsiveText(context, 14.0),
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        bodySmall: TextStyle(
          fontSize: responsiveText(context, 14.0),
          fontWeight: FontWeight.w500,
          color: Colors.black.withValues(alpha: 0.5),
        ),
        labelLarge: TextStyle(
          fontSize: responsiveText(context, 12.0),
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
        labelMedium: TextStyle(
          fontSize: responsiveText(context, 12.0),
          fontWeight: FontWeight.normal,
          color: Colors.black.withValues(alpha: 0.5),
        ),
  );


  static TextTheme darkTextTheme(BuildContext context) => TextTheme(
        headlineLarge: TextStyle(
          fontSize: responsiveText(context, 32.0),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: responsiveText(context, 24.0),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: responsiveText(context, 18.0),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: responsiveText(context, 16.0),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: responsiveText(context, 16.0),
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: responsiveText(context, 16.0),
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: responsiveText(context, 14.0),
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: responsiveText(context, 14.0),
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: responsiveText(context, 14.0),
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        labelLarge: TextStyle(
          fontSize: responsiveText(context, 12.0),
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: responsiveText(context, 12.0),
          fontWeight: FontWeight.normal,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      );
}
import 'package:flutter/material.dart';

class CustomColors {
  CustomColors._();
  //App Basic Colors
  static const Color primary = Color(0xFF002366);
  static const Color secondary = Color(0xFFFFE24B);
  static const Color accent = Color(0xFFb0c7ff);
  static const Color secondaryBlue = Color(0xFF090c44);
  static const Color alternate = Color(0xFF8CAAD2);
  //D2B48C
  //5C523E

  //Gradient Colors
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [
        Color(0xFF003366),
        // Color(0xFF11181C),
        Color(0xFF0f52ba),
      ],
  );

  //profile colors
  static const Color profileColor1  = Color(0xFFc67878);
  static const Color profileColor2 = Color(0xFF564761);
  static const Color profileColor3 = Color(0xFF425563);
  static const Color profileColor4 = Color(0xFFD2B48C);

  //Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  //Background colors
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF121212);
  static const Color primaryBackground = Color(0xFFF3F5FF);

  //Background Container Colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static const Color darkContainer = Color(0xFF272727);

  //Button Colors
  static const Color buttonPrimary = Color(0xFF090d47);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);
  
  //Border Colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);
  
  //Error and Validating Colors
  static const Color error = Color.fromARGB(255, 148, 16, 16);
  static const Color success = Color.fromARGB(255, 12, 92, 18);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  
  //Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color gold = Color(0xFFFFD700);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color lightPrimary = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}
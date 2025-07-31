import 'package:flutter/material.dart';
import '../../utils/constants/custom_colors.dart';

class ShadowStyle {

  static final verticalProductShadow = BoxShadow(
    color:  CustomColors.primary.withValues(alpha: 0.15),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2)
  );

  static final horizontalProductShadow = BoxShadow(
    color: CustomColors.darkGrey.withValues(alpha: 0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2)    
  );
}
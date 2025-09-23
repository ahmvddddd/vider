import 'package:flutter/material.dart';

const double baseHeight = 800.0;
const double baseWidth = 360.0;

double widgetScale(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  final heightFactor = screenHeight / baseHeight;
  final widthFactor = screenWidth / baseWidth;

  return (widthFactor < heightFactor) ? widthFactor : heightFactor;
}

double textScale(BuildContext context) {
  double factor = widgetScale(context);

  return factor.clamp(0.9, 1.1);
}

double responsiveSize(BuildContext context, double size) {
  return size * widgetScale(context);
}

double responsiveText(BuildContext context, double fontSize) {
  return fontSize * textScale(context);
}
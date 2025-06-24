import 'package:flutter/material.dart';

// Utility class to create responsive dimensions
class ResponsiveDimensions {
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 700;
  }

  static double scaledSize(BuildContext context, double size) {
    final isSmall = isSmallScreen(context);
    return isSmall ? size * 0.8 : size;
  }

  static EdgeInsets scaledPadding(BuildContext context, EdgeInsets padding) {
    final scale = isSmallScreen(context) ? 0.7 : 1.0;
    return EdgeInsets.only(
      top: padding.top * scale,
      left: padding.left * scale,
      right: padding.right * scale,
      bottom: padding.bottom * scale,
    );
  }
}

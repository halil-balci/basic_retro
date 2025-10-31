import 'package:flutter/material.dart';

/// Responsive design mixin for widgets
/// Provides helper methods for responsive sizing and layout decisions
/// Uses only 2 breakpoints: Small (mobile) and Large (desktop/tablet)
mixin ResponsiveMixin {
  /// Breakpoint for small screens (mobile)
  /// Small: < 600px, Large: >= 600px
  static const double _smallScreenBreakpoint = 600.0;

  /// Check if screen is small (mobile) - vertical layout
  bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < _smallScreenBreakpoint;
  }

  /// Check if screen is large (desktop/tablet) - horizontal layout
  bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= _smallScreenBreakpoint;
  }

  /// Get responsive padding based on screen size
  double getResponsivePadding(BuildContext context, {
    double small = 16.0,
    double large = 24.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }

  /// Get responsive margin based on screen size
  double getResponsiveMargin(BuildContext context, {
    double small = 12.0,
    double large = 20.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }

  /// Get responsive font size based on screen size
  double getResponsiveFontSize(BuildContext context, {
    double small = 14.0,
    double large = 16.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }

  /// Get responsive title font size based on screen size
  double getResponsiveTitleSize(BuildContext context, {
    double small = 16.0,
    double large = 18.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }

  /// Get responsive icon size based on screen size
  double getResponsiveIconSize(BuildContext context, {
    double small = 20.0,
    double large = 24.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }

  /// Get responsive spacing based on screen size
  double getResponsiveSpacing(BuildContext context, {
    double small = 8.0,
    double large = 16.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }

  /// Get responsive border radius based on screen size
  double getResponsiveBorderRadius(BuildContext context, {
    double small = 8.0,
    double large = 12.0,
  }) {
    return isSmallScreen(context) ? small : large;
  }
}

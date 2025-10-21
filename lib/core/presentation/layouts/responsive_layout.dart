import 'package:flutter/material.dart';

/// Responsive layout wrapper that combines responsive_framework with LayoutBuilder
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool useResponsiveWrapper;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.useResponsiveWrapper = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return child;
      },
    );
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (screenWidth >= ResponsiveBreakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Check if mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;
  }

  /// Check if tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.tablet && 
           width < ResponsiveBreakpoints.desktop;
  }

  /// Check if desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ResponsiveBreakpoints.desktop;
  }
}

/// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 450;
  static const double tablet = 800;
  static const double desktop = 1200;
}

/// Extension for responsive sizes
extension ResponsiveSizes on BuildContext {
  double get responsivePadding {
    return ResponsiveLayout.getResponsiveValue(
      context: this,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  double get responsiveMargin {
    return ResponsiveLayout.getResponsiveValue(
      context: this,
      mobile: 8.0,
      tablet: 12.0,
      desktop: 16.0,
    );
  }

  double get responsiveFontSize {
    return ResponsiveLayout.getResponsiveValue(
      context: this,
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );
  }

  double get responsiveTitleSize {
    return ResponsiveLayout.getResponsiveValue(
      context: this,
      mobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
  }

  bool get isMobile => ResponsiveLayout.isMobile(this);
  bool get isTablet => ResponsiveLayout.isTablet(this);
  bool get isDesktop => ResponsiveLayout.isDesktop(this);
}

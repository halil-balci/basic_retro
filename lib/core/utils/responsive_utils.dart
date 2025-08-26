/// Utility class for consistent responsive design across the application
class ResponsiveUtils {
  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 900;
  static const double desktopMaxWidth = 1200;
  
  // Very small screen (phones in portrait)
  static const double verySmallMaxWidth = 400;
  
  /// Check if the screen is mobile sized
  static bool isMobile(double width) => width < mobileMaxWidth;
  
  /// Check if the screen is very small (small phone)
  static bool isVerySmall(double width) => width < verySmallMaxWidth;
  
  /// Check if the screen is tablet sized
  static bool isTablet(double width) => 
      width >= mobileMaxWidth && width < tabletMaxWidth;
  
  /// Check if the screen is desktop sized
  static bool isDesktop(double width) => width >= tabletMaxWidth;
  
  /// Check if the screen is large desktop
  static bool isLargeDesktop(double width) => width >= desktopMaxWidth;
  
  /// Get responsive font size
  static double getFontSize(double width, {
    double small = 12,
    double medium = 14,
    double large = 16,
  }) {
    if (isVerySmall(width)) return small;
    if (isMobile(width)) return medium;
    return large;
  }
  
  /// Get responsive padding
  static double getPadding(double width, {
    double small = 8,
    double medium = 16,
    double large = 24,
  }) {
    if (isVerySmall(width)) return small;
    if (isMobile(width)) return medium;
    return large;
  }
  
  /// Get responsive spacing
  static double getSpacing(double width, {
    double small = 4,
    double medium = 8,
    double large = 12,
  }) {
    if (isVerySmall(width)) return small;
    if (isMobile(width)) return medium;
    return large;
  }
  
  /// Get responsive icon size
  static double getIconSize(double width, {
    double small = 16,
    double medium = 20,
    double large = 24,
  }) {
    if (isVerySmall(width)) return small;
    if (isMobile(width)) return medium;
    return large;
  }
  
  /// Get responsive button height
  static double getButtonHeight(double width, {
    double small = 36,
    double medium = 44,
    double large = 48,
  }) {
    if (isVerySmall(width)) return small;
    if (isMobile(width)) return medium;
    return large;
  }
  
  /// Get number of columns for grid layouts
  static int getGridColumns(double width, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isMobile(width)) return mobile;
    if (isTablet(width)) return tablet;
    return desktop;
  }
  
  /// Get responsive border radius
  static double getBorderRadius(double width, {
    double small = 6,
    double medium = 8,
    double large = 12,
  }) {
    if (isVerySmall(width)) return small;
    if (isMobile(width)) return medium;
    return large;
  }
  
  /// Get responsive AppBar height
  static double getAppBarHeight(double width) {
    return isMobile(width) ? 64 : 56;
  }
}

/// Extension to make responsive utilities easier to use
extension ResponsiveExtension on double {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isVerySmall => ResponsiveUtils.isVerySmall(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLargeDesktop => ResponsiveUtils.isLargeDesktop(this);
}

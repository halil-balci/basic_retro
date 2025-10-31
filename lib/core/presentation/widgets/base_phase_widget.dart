import 'package:flutter/material.dart';
import '../mixins/responsive_mixin.dart';

/// Base abstract class for all phase widgets
/// Implements SOLID principles:
/// - Single Responsibility: Handles common phase widget behavior
/// - Open/Closed: Open for extension, closed for modification
/// - Liskov Substitution: All phase widgets can be used interchangeably
/// Uses 2-tier responsive design: Small (vertical) and Large (horizontal)
abstract class BasePhaseWidget extends StatelessWidget with ResponsiveMixin {
  const BasePhaseWidget({super.key});

  /// Phase title to display in header
  String get phaseTitle;

  /// Phase description to display in header
  String get phaseDescription;

  /// Phase icon to display in header
  IconData get phaseIcon;

  /// Phase gradient colors
  List<Color> get phaseGradientColors;

  /// Build the main content of the phase
  /// This method must be implemented by each phase widget
  /// isSmallScreen: true for vertical layout (mobile), false for horizontal layout (desktop/tablet)
  Widget buildPhaseContent(BuildContext context, bool isSmallScreen);

  /// Optional: Additional info to display in header
  String? getAdditionalInfo(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    final isSmall = isSmallScreen(context);
    final padding = getResponsivePadding(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          _buildPhaseHeader(context, isSmall),
          SizedBox(height: getResponsiveSpacing(context, small: 16, large: 24)),
          buildPhaseContent(context, isSmall),
        ],
      ),
    );
  }

  /// Build the common phase header
  Widget _buildPhaseHeader(BuildContext context, bool isSmall) {
    final additionalInfo = getAdditionalInfo(context);
    final iconSize = getResponsiveIconSize(context);
    final titleSize = getResponsiveTitleSize(context);
    final descSize = getResponsiveFontSize(context, small: 13, large: 14);
    final headerPadding = getResponsivePadding(context, small: 16, large: 20);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: phaseGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          getResponsiveBorderRadius(context),
        ),
      ),
      child: isSmall
          ? _buildSmallScreenHeader(additionalInfo, iconSize, titleSize, descSize)
          : _buildLargeScreenHeader(additionalInfo, iconSize, titleSize, descSize),
    );
  }

  /// Build header for small screens (vertical layout)
  Widget _buildSmallScreenHeader(String? additionalInfo, double iconSize, double titleSize, double descSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                phaseIcon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              phaseTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          phaseDescription,
          style: TextStyle(
            color: Colors.white,
            fontSize: descSize,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build header for large screens (horizontal layout)
  Widget _buildLargeScreenHeader(String? additionalInfo, double iconSize, double titleSize, double descSize) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                phaseIcon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phaseTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (additionalInfo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      additionalInfo,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: descSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          phaseDescription,
          style: TextStyle(
            color: Colors.white,
            fontSize: descSize,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

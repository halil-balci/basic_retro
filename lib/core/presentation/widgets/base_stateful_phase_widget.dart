import 'package:flutter/material.dart';
import '../mixins/responsive_mixin.dart';

/// Base abstract class for stateful phase widgets
/// Implements SOLID principles:
/// - Single Responsibility: Handles common phase widget behavior
/// - Open/Closed: Open for extension, closed for modification
abstract class BaseStatefulPhaseWidget extends StatefulWidget {
  const BaseStatefulPhaseWidget({super.key});

  /// Phase title to display in header
  String get phaseTitle;

  /// Phase description to display in header
  String get phaseDescription;

  /// Phase icon to display in header
  IconData get phaseIcon;

  /// Phase gradient colors
  List<Color> get phaseGradientColors;

  @override
  BaseStatefulPhaseState createState();
}

/// Base state class for stateful phase widgets
abstract class BaseStatefulPhaseState<T extends BaseStatefulPhaseWidget> extends State<T> with ResponsiveMixin {
  
  /// Build the main content of the phase
  /// This method must be implemented by each phase widget
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
          buildPhaseHeader(context, isSmall),
          SizedBox(height: getResponsiveSpacing(context, small: 16, large: 24)),
          buildPhaseContent(context, isSmall),
        ],
      ),
    );
  }

  /// Build the common phase header
  Widget buildPhaseHeader(BuildContext context, bool isSmall) {
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
          colors: widget.phaseGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          getResponsiveBorderRadius(context),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmall ? 6 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.phaseIcon,
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
                      widget.phaseTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (additionalInfo != null) ...[
                      SizedBox(height: isSmall ? 2 : 4),
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
            widget.phaseDescription,
            style: TextStyle(
              color: Colors.white,
              fontSize: descSize,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Helper method to get category icon
  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'went_well':
      case 'keep':
        return Icons.thumb_up_rounded;
      case 'to_improve':
      case 'stop':
        return Icons.thumb_down_rounded;
      case 'action_items':
      case 'start':
        return Icons.lightbulb_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  /// Helper method to get category color
  Color getCategoryColor(String category) {
    final colorName = _getCategoryColorName(category);
    switch (colorName) {
      case 'green':
        return const Color(0xFF10B981);
      case 'red':
        return const Color(0xFFEF4444);
      case 'blue':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getCategoryColorName(String category) {
    // This should ideally come from RetroConstants
    switch (category) {
      case 'went_well':
      case 'keep':
        return 'green';
      case 'to_improve':
      case 'stop':
        return 'red';
      case 'action_items':
      case 'start':
        return 'blue';
      default:
        return 'gray';
    }
  }
}

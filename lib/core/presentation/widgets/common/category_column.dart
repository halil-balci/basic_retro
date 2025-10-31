import 'package:flutter/material.dart';
import '../../mixins/responsive_mixin.dart';
import '../../../constants/retro_constants.dart';

/// Common category column widget used across different phases
/// Follows Single Responsibility Principle - only handles category display
/// Preserves original TextField design from editing_phase_widget
class CategoryColumn extends StatelessWidget with ResponsiveMixin {
  final String category;
  final Color color;
  final Widget child;

  const CategoryColumn({
    super.key,
    required this.category,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = isSmallScreen(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isSmall),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getCategoryIcon(category),
            color: color,
            size: isSmall ? 20 : 24,
          ),
          SizedBox(height: isSmall ? 6 : 8),
          Text(
            RetroConstants.categoryTitles[category] ?? category,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
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
}

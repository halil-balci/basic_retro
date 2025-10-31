import 'package:flutter/material.dart';
import '../../mixins/responsive_mixin.dart';

/// Common vote badge widget
/// Displays vote count with color indicator
class VoteBadge extends StatelessWidget with ResponsiveMixin {
  final int voteCount;
  final Color color;

  const VoteBadge({
    super.key,
    required this.voteCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = getResponsiveFontSize(context, small: 11, large: 12);
    final isSmall = isSmallScreen(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: fontSize + 2,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$voteCount',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

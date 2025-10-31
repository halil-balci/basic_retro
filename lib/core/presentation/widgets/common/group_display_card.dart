import 'package:flutter/material.dart';
import '../../../../features/retro/domain/entities/thought_group.dart';
import '../../../../features/retro/domain/entities/retro_thought.dart';
import '../../../constants/retro_constants.dart';

/// Common widget for displaying a discussion group with its thoughts
class GroupDisplayCard extends StatelessWidget {
  final ThoughtGroup group;
  final int rank;
  final int totalGroups;
  final bool isSmallScreen;

  const GroupDisplayCard({
    super.key,
    required this.group,
    required this.rank,
    required this.totalGroups,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isVerySmallScreen = MediaQuery.of(context).size.width < 400;
    
    // Group thoughts by category for better display
    final thoughtsByCategory = <String, List<RetroThought>>{};
    for (final thought in group.thoughts) {
      thoughtsByCategory.putIfAbsent(thought.category, () => []).add(thought);
    }

    return Card(
      elevation: 6,
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 24.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _getPriorityColor(rank).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getPriorityColor(rank).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header with priority and stats
            _buildHeader(isVerySmallScreen),
            SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
            Text(
              'Items in this group:',
              style: TextStyle(
                fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF374151),
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
            ...thoughtsByCategory.entries.map((entry) {
              final categoryName = entry.key;
              final categoryThoughts = entry.value;
              final categoryIndex = thoughtsByCategory.keys.toList().indexOf(categoryName);
              
              return _buildCategorySection(
                categoryName,
                categoryThoughts,
                thoughtsByCategory.length,
                categoryIndex,
                isVerySmallScreen,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isVerySmallScreen) {
    return isSmallScreen 
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriorityBadge(isVerySmallScreen),
            SizedBox(height: isVerySmallScreen ? 6 : 8),
            _buildStats(isVerySmallScreen),
          ],
        )
      : Row(
          children: [
            _buildPriorityBadge(isVerySmallScreen),
            const Spacer(),
            _buildStats(isVerySmallScreen),
          ],
        );
  }

  Widget _buildPriorityBadge(bool isVerySmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
        vertical: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8),
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor(rank),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(rank),
            color: Colors.white,
            size: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20),
          ),
          SizedBox(width: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8)),
          Flexible(
            child: Text(
              'Priority #$rank',
              style: TextStyle(
                color: Colors.white,
                fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(bool isVerySmallScreen) {
    return Wrap(
      spacing: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
      runSpacing: 4,
      children: [
        _buildStatBadge(
          icon: Icons.favorite,
          iconColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFF3F4F6),
          borderColor: const Color(0xFFE5E7EB),
          textColor: const Color(0xFF374151),
          value: '${group.votes}${isSmallScreen && !isVerySmallScreen ? '' : ' votes'}',
          isVerySmallScreen: isVerySmallScreen,
        ),
        _buildStatBadge(
          icon: Icons.group_work,
          iconColor: const Color(0xFF0284C7),
          backgroundColor: const Color(0xFFF0F9FF),
          borderColor: const Color(0xFFBAE6FD),
          textColor: const Color(0xFF0C4A6E),
          value: '${group.thoughts.length}${isSmallScreen && !isVerySmallScreen ? '' : ' items'}',
          isVerySmallScreen: isVerySmallScreen,
        ),
      ],
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required String value,
    required bool isVerySmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
        vertical: isVerySmallScreen ? 2 : (isSmallScreen ? 4 : 6),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 16)),
          SizedBox(width: isVerySmallScreen ? 1 : (isSmallScreen ? 2 : 4)),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: isVerySmallScreen ? 9 : (isSmallScreen ? 10 : 12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    String categoryName,
    List<RetroThought> categoryThoughts,
    int totalCategories,
    int categoryIndex,
    bool isVerySmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header if more than one category
        if (totalCategories > 1) ...[
          Container(
            margin: EdgeInsets.only(
              bottom: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
              vertical: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8),
            ),
            decoration: BoxDecoration(
              color: _getCategoryColor(categoryName).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getCategoryColor(categoryName).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(categoryName),
                  color: _getCategoryColor(categoryName),
                  size: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                ),
                SizedBox(width: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8)),
                Flexible(
                  child: Text(
                    RetroConstants.categoryTitles[categoryName] ?? categoryName,
                    style: TextStyle(
                      fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(categoryName),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        // Show all thoughts from this category
        ...categoryThoughts.map((thought) {
          return Container(
            margin: EdgeInsets.only(
              bottom: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
            ),
            padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getCategoryColor(categoryName).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(categoryName),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
                  Expanded(
                    child: SelectableText(
                      thought.content,
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (totalCategories > 1 && categoryIndex < totalCategories - 1)
          SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
      ],
    );
  }

  Color _getPriorityColor(int rank) {
    if (rank <= 3) return const Color(0xFF6366F1); // Soft indigo for high priority
    if (rank <= 6) return const Color(0xFF8B5CF6); // Soft purple for medium priority
    return const Color(0xFF06B6D4); // Soft cyan for low priority
  }

  IconData _getPriorityIcon(int rank) {
    if (rank <= 3) return Icons.priority_high;
    if (rank <= 6) return Icons.trending_up;
    return Icons.info_outline;
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mad':
        return Icons.not_interested;
      case 'Sad':
        return Icons.thumb_down_rounded;
      case 'Glad':
        return Icons.thumb_up_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'start':
        return const Color(0xFF10B981);
      case 'stop':
        return const Color(0xFFEF4444);
      case 'continue':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }
}

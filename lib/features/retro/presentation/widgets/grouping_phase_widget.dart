import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/retro_thought.dart';
import '../../domain/entities/thought_group.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';
import '../../../../core/presentation/widgets/base_stateful_phase_widget.dart';

class GroupingPhaseWidget extends BaseStatefulPhaseWidget {
  const GroupingPhaseWidget({super.key});

  @override
  String get phaseTitle => 'Grouping Phase';

  @override
  String get phaseDescription => 'Drag and drop thoughts to create groups. Similar thoughts work better together!';

  @override
  IconData get phaseIcon => Icons.workspaces;

  @override
  List<Color> get phaseGradientColors => const [Color(0xFF4F46E5), Color(0xFF3730A3)];

  @override
  BaseStatefulPhaseState<GroupingPhaseWidget> createState() => _GroupingPhaseWidgetState();
}

class _GroupingPhaseWidgetState extends BaseStatefulPhaseState<GroupingPhaseWidget> {

  @override
  String? getAdditionalInfo(BuildContext context) {
    final viewModel = Provider.of<RetroViewModel>(context);
    
    // Count explicit groups (multi-thought groups from Firebase)
    final explicitGroups = viewModel.currentGroups.length;
    
    // Count individual thoughts (not in any group)
    final thoughtsInGroups = viewModel.currentGroups
        .expand((group) => group.thoughts)
        .map((t) => t.id)
        .toSet();
    
    final individualThoughts = viewModel.thoughts
        .where((thought) => !thoughtsInGroups.contains(thought.id))
        .length;
    
    final totalGroups = explicitGroups + individualThoughts;
    return 'There are $totalGroups groups.';
  }

  @override
  Widget buildPhaseContent(BuildContext context, bool isSmallScreen) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return isSmallScreen
          ? Column(
              children: RetroConstants.categories.map((category) {
                final colorName = RetroConstants.categoryColors[category] ?? 'grey';
                final categoryColor = _getColorFromName(colorName);
                
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: category != RetroConstants.categories.last ? 16 : 0,
                  ),
                  child: _buildGroupingCategoryColumn(category, categoryColor, viewModel, isSmallScreen),
                );
              }).toList(),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: RetroConstants.categories.map((category) {
                final colorName = RetroConstants.categoryColors[category] ?? 'grey';
                final categoryColor = _getColorFromName(colorName);
                
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: category != RetroConstants.categories.last ? 16 : 0,
                    ),
                    child: _buildGroupingCategoryColumn(category, categoryColor, viewModel, isSmallScreen),
                  ),
                );
              }).toList(),
            );
      },
    );
  }

  Widget _buildGroupingCategoryColumn(String category, Color color, RetroViewModel viewModel, bool isSmallScreen) {
    return Container(
      constraints: isSmallScreen 
        ? null 
        : const BoxConstraints(
            minHeight: 200,
          ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
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
                  size: isSmallScreen ? 20 : 24,
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  RetroConstants.categoryTitles[category] ?? category,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Content area
          Container(
            constraints: BoxConstraints(
              minHeight: isSmallScreen ? 80 : 120,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: _buildCategoryContent(category, viewModel),
          ),
        ],
      ),
    );
  }

  /// Build the content for a category column, using Firebase groups as source of truth
  Widget _buildCategoryContent(String category, RetroViewModel viewModel) {
    final categoryThoughts = viewModel.thoughtsByCategory[category] ?? <RetroThought>[];
    
    if (categoryThoughts.isEmpty) {
      return Center(
        child: Text(
          'No thoughts in this category',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    // Build a mapping: thoughtId -> group (from Firebase groups)
    final thoughtToGroup = <String, ThoughtGroup>{};
    for (final group in viewModel.currentGroups) {
      for (final thought in group.thoughts) {
        thoughtToGroup[thought.id] = group;
      }
    }
    
    final widgets = <Widget>[];
    final processedThoughts = <String>{};
    final processedGroups = <String>{};
    
    for (final thought in categoryThoughts) {
      if (processedThoughts.contains(thought.id)) continue;
      
      final group = thoughtToGroup[thought.id];
      
      if (group != null && group.thoughts.length > 1) {
        // This thought is in a multi-thought group
        // Show the group card once, in its primary category (first thought's category)
        final primaryCategory = group.thoughts.first.category;
        
        if (primaryCategory == category && !processedGroups.contains(group.id)) {
          widgets.add(Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _GroupCard(
              groupId: group.id,
              thoughts: group.thoughts,
              onSplit: () => _splitGroup(group.id, viewModel),
              viewModel: viewModel,
              onAddToGroup: (droppedThought) => _addThoughtToGroup(droppedThought, group.id, viewModel),
            ),
          ));
          
          processedGroups.add(group.id);
          for (final groupThought in group.thoughts) {
            processedThoughts.add(groupThought.id);
          }
        } else {
          // Group shown in another category, mark as processed
          processedThoughts.add(thought.id);
        }
      } else {
        // Ungrouped thought (or in a single-thought group) — show as individual draggable card
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _DraggableThoughtCard(
            thought: thought,
            viewModel: viewModel,
            onGroupWith: (targetThought) => _createGroup([thought, targetThought], viewModel),
          ),
        ));
        processedThoughts.add(thought.id);
      }
    }
    
    if (widgets.isEmpty) {
      return Center(
        child: Text(
          'Drag thoughts here to group them',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  /// Create a new group from multiple thoughts — atomic Firebase operation
  void _createGroup(List<RetroThought> thoughts, RetroViewModel viewModel) async {
    try {
      await viewModel.mergeThoughtsToNewGroup(thoughts);
    } catch (e) {
      debugPrint('Error creating group: $e');
    }
  }

  /// Split a group — atomic Firebase operation
  void _splitGroup(String groupId, RetroViewModel viewModel) async {
    try {
      await viewModel.splitGroupAtomic(groupId);
    } catch (e) {
      debugPrint('Error splitting group: $e');
    }
  }

  /// Add a thought to an existing group — atomic Firebase operation
  void _addThoughtToGroup(RetroThought thought, String groupId, RetroViewModel viewModel) async {
    try {
      await viewModel.addThoughtToExistingGroup(groupId, thought);
    } catch (e) {
      debugPrint('Error adding thought to group: $e');
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Start':
        return Icons.lightbulb_rounded;
      case 'Stop':
        return Icons.thumb_down_rounded;
      case 'Continue':
        return Icons.thumb_up_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
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
}

class _DraggableThoughtCard extends StatelessWidget {
  final RetroThought thought;
  final RetroViewModel viewModel;
  final Function(RetroThought) onGroupWith;

  const _DraggableThoughtCard({
    required this.thought,
    required this.viewModel,
    required this.onGroupWith,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<RetroThought>(
      onWillAccept: (data) {
        return data != null && data.id != thought.id;
      },
      onAccept: (droppedThought) {
        onGroupWith(droppedThought);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Draggable<RetroThought>(
          data: thought,
          feedback: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                thought.content,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: _buildThoughtCard(isHighlighted),
          ),
          child: _buildThoughtCard(isHighlighted),
        );
      },
    );
  }

  Widget _buildThoughtCard(bool isHighlighted) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isHighlighted ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isHighlighted ? Colors.blue : const Color(0xFFE2E8F0),
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: Text(
          thought.content,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String groupId;
  final List<RetroThought> thoughts;
  final VoidCallback onSplit;
  final RetroViewModel viewModel;
  final Function(RetroThought)? onAddToGroup;

  const _GroupCard({
    required this.groupId,
    required this.thoughts,
    required this.onSplit,
    required this.viewModel,
    this.onAddToGroup,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<RetroThought>(
      onWillAccept: (data) {
        return data != null && 
               thoughts.isNotEmpty && 
               !thoughts.any((t) => t.id == data.id);
      },
      onAccept: (droppedThought) {
        onAddToGroup?.call(droppedThought);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isHighlighted ? Colors.amber.shade100 : Colors.amber.shade50,
              border: Border.all(
                color: isHighlighted ? Colors.amber.shade800 : Colors.amber,
                width: isHighlighted ? 3 : 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.group_work, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Group (${thoughts.length} items)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onSplit,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.call_split,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...thoughts.take(2).map((thought) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    thought.content,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                if (thoughts.length > 2)
                  Text(
                    '+${thoughts.length - 2} more...',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

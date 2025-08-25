import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

class GroupingPhaseWidget extends StatefulWidget {
  const GroupingPhaseWidget({super.key});

  @override
  State<GroupingPhaseWidget> createState() => _GroupingPhaseWidgetState();
}

class _GroupingPhaseWidgetState extends State<GroupingPhaseWidget> {
  // Map to track groups - each group has an ID and list of thoughts
  Map<String, List<RetroThought>> _thoughtGroups = {};
  // Map to track which group each thought belongs to
  Map<String, String> _thoughtToGroupMapping = {};
  int _nextGroupId = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            
            return SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Column(
                children: [
                  // Header card similar to editing phase
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.group_work,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Grouping Phase',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 16 : 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: isSmallScreen ? 2 : 4),
                                  Text(
                                    '${_thoughtGroups.length} groups created.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 13 : 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Drag thoughts on top of each other to create groups.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Responsive layout - vertical on small screens, horizontal on large screens
                  isSmallScreen
                    ? Column(
                        children: RetroConstants.categories.map((category) {
                          Color categoryColor;
                          switch (RetroConstants.categoryColors[category]) {
                            case 'green':
                              categoryColor = const Color(0xFF10B981);
                              break;
                            case 'red':
                              categoryColor = const Color(0xFFEF4444);
                              break;
                            case 'blue':
                              categoryColor = const Color(0xFF3B82F6);
                              break;
                            default:
                              categoryColor = const Color(0xFF6B7280);
                          }
                          
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
                          Color categoryColor;
                          switch (RetroConstants.categoryColors[category]) {
                            case 'green':
                              categoryColor = const Color(0xFF10B981);
                              break;
                            case 'red':
                              categoryColor = const Color(0xFFEF4444);
                              break;
                            case 'blue':
                              categoryColor = const Color(0xFF3B82F6);
                              break;
                            default:
                              categoryColor = const Color(0xFF6B7280);
                          }
                          
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                right: category != RetroConstants.categories.last ? 16 : 0,
                              ),
                              child: _buildGroupingCategoryColumn(category, categoryColor, viewModel, isSmallScreen),
                            ),
                          );
                        }).toList(),
                      ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupingCategoryColumn(String category, Color color, RetroViewModel viewModel, bool isSmallScreen) {
    return Container(
      constraints: isSmallScreen 
        ? null 
        : const BoxConstraints(
            minHeight: 200, // Minimum height for drag-drop on large screens
          ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
          // Drop target area for grouping
          DragTarget<RetroThought>(
            onWillAccept: (data) {
              return data != null;
            },
            onAccept: (thought) {
              _moveThoughtToCategory(thought, category, viewModel);
            },
            builder: (context, candidateData, rejectedData) {
              final isHighlighted = candidateData.isNotEmpty;
              final thoughtsList = _buildDraggableThoughtsList(category, viewModel);
              
              return Container(
                constraints: BoxConstraints(
                  minHeight: thoughtsList.isEmpty ? (isSmallScreen ? 80 : 120) : 0, // Responsive minimal height
                ),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: isHighlighted 
                      ? color.withOpacity(0.1) 
                      : Colors.transparent,
                  border: isHighlighted
                      ? Border.all(color: color, width: 2)
                      : null,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: thoughtsList.isEmpty
                  ? Center(
                      child: Text(
                        isHighlighted 
                          ? 'Drop here to group' 
                          : 'Drag thoughts here to group them',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: isSmallScreen ? 12 : 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: thoughtsList,
                    ),
              );
            },
          ),
        ],
      ),
    );
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

  List<Widget> _buildDraggableThoughtsList(String category, RetroViewModel viewModel) {
    final thoughts = viewModel.thoughtsByCategory[category] ?? <RetroThought>[];
    
    if (thoughts.isEmpty) {
      return [
        Container(
          height: 100,
          alignment: Alignment.center,
          child: Text(
            'Drop thoughts here',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ];
    }
    
    final widgets = <Widget>[];
    final processedThoughts = <String>{}; // Track which thoughts we've already processed
    final processedGroups = <String>{}; // Track which groups we've already processed
    
    for (final thought in thoughts) {
      if (processedThoughts.contains(thought.id)) {
        continue; // Skip if we've already processed this thought as part of a group
      }
      
      final groupId = _thoughtToGroupMapping[thought.id];
      
      if (groupId != null && _thoughtGroups[groupId] != null && _thoughtGroups[groupId]!.length > 1) {
        // Check if this group should be displayed in this category
        final groupThoughts = _thoughtGroups[groupId]!;
        final primaryCategory = groupThoughts.first.category; // Use first thought's category as primary
        
        if (primaryCategory == category && !processedGroups.contains(groupId)) {
          // This group belongs to this category and hasn't been processed yet
          widgets.add(Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _GroupCard(
              groupId: groupId,
              thoughts: groupThoughts,
              onSplit: () => _splitGroup(groupId),
              viewModel: viewModel,
              onAddToGroup: (thought) => _addThoughtToGroup(thought, groupId),
            ),
          ));
          
          processedGroups.add(groupId);
          
          // Mark all thoughts in this group as processed
          for (final groupThought in groupThoughts) {
            processedThoughts.add(groupThought.id);
          }
        } else {
          // This thought belongs to a group in another category or already processed, mark as processed
          processedThoughts.add(thought.id);
        }
      } else if (!processedThoughts.contains(thought.id)) {
        // This is a single thought that belongs to this category
        widgets.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _DraggableThoughtCard(
            thought: thought,
            viewModel: viewModel,
            onGroupWith: (targetThought) => _createGroup([thought, targetThought]),
          ),
        ));
        processedThoughts.add(thought.id);
      }
    }
    
    return widgets;
  }

  void _createGroup(List<RetroThought> thoughts) {
    setState(() {
      final groupId = 'group_${_nextGroupId++}';
      _thoughtGroups[groupId] = thoughts;
      
      // Update mapping for all thoughts in the group
      for (final thought in thoughts) {
        _thoughtToGroupMapping[thought.id] = groupId;
      }
    });
    
    // Save groups to ViewModel whenever groups are created/modified
    _saveGroupsToViewModel();
  }

  Future<void> _saveGroupsToViewModel() async {
    final viewModel = Provider.of<RetroViewModel>(context, listen: false);
    
    try {
      // Clear existing groups first
      await viewModel.clearGroups();
      
      // Convert local groups to ThoughtGroup objects and save them
      for (final entry in _thoughtGroups.entries) {
        final thoughts = entry.value;
        
        if (thoughts.isNotEmpty) {
          // Group name based on primary category and contents
          final primaryCategory = thoughts.first.category;
          final categoryCounts = <String, int>{};
          for (final thought in thoughts) {
            categoryCounts[thought.category] = (categoryCounts[thought.category] ?? 0) + 1;
          }
          
          String groupName;
          if (categoryCounts.length == 1) {
            // Single category group
            groupName = 'Group from $primaryCategory (${thoughts.length} items)';
          } else {
            // Multi-category group
            final categoryList = categoryCounts.entries
                .map((e) => '${e.value} ${e.key}')
                .join(', ');
            groupName = 'Mixed Group ($categoryList)';
          }
          
          await viewModel.createGroup(
            groupName,
            thoughts,
            0.0,
            0.0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving groups to ViewModel: $e');
    }
  }

  void _splitGroup(String groupId) {
    setState(() {
      final thoughts = _thoughtGroups[groupId];
      if (thoughts != null) {
        // Remove group mapping for all thoughts
        for (final thought in thoughts) {
          _thoughtToGroupMapping.remove(thought.id);
        }
        // Remove the group
        _thoughtGroups.remove(groupId);
      }
    });
    
    // Save groups to ViewModel after splitting
    _saveGroupsToViewModel();
  }

  void _addThoughtToGroup(RetroThought thought, String groupId) {
    setState(() {
      // Remove from any existing group
      final oldGroupId = _thoughtToGroupMapping[thought.id];
      if (oldGroupId != null && oldGroupId != groupId) {
        _thoughtGroups[oldGroupId]?.remove(thought);
        if (_thoughtGroups[oldGroupId]?.isEmpty ?? false) {
          _thoughtGroups.remove(oldGroupId);
        }
      }
      
      // Add to new group
      _thoughtToGroupMapping[thought.id] = groupId;
      _thoughtGroups[groupId]?.add(thought);
    });
    
    // Save groups to ViewModel after adding thought to group
    _saveGroupsToViewModel();
  }

  void _moveThoughtToCategory(RetroThought thought, String newCategory, RetroViewModel viewModel) {
    // This would update the thought's category in the real implementation
    debugPrint('Moved "${thought.content}" to $newCategory');
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
                    color: Colors.black.withOpacity(0.2),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/thought_group.dart';
import '../../domain/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

class GroupingPhaseWidget extends StatefulWidget {
  const GroupingPhaseWidget({super.key});

  @override
  State<GroupingPhaseWidget> createState() => _GroupingPhaseWidgetState();
}

class _GroupingPhaseWidgetState extends State<GroupingPhaseWidget> {
  List<GroupItem> _groupItems = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeItems();
    });
  }

  void _initializeItems([List<RetroThought>? thoughts]) {
    if (_isInitialized) return;
    
    final viewModel = Provider.of<RetroViewModel>(context, listen: false);
    final thoughtsToUse = thoughts ?? viewModel.thoughts;
    
    setState(() {
      _groupItems = thoughtsToUse.asMap().entries.map((entry) {
        final index = entry.key;
        final thought = entry.value;
        final col = index % 3;
        final row = index ~/ 3;
        
        return GroupItem(
          id: thought.id,
          thoughts: [thought],
          position: Offset(
            col * 200.0 + 20,
            row * 120.0 + 20,
          ),
        );
      }).toList();
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        // Initialize items only once when we have thoughts and haven't initialized
        if (!_isInitialized && viewModel.thoughts.isNotEmpty) {
          // Use a microtask to avoid setState during build
          Future.microtask(() {
            if (mounted && !_isInitialized) {
              _initializeItems(viewModel.thoughts);
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.orange.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group_work, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          Text(
                            'Grouping Phase',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Drag similar thoughts together to create groups. Click on a group to rename it.',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Groups: ${_groupItems.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildGroupingArea(),
              ),
              const SizedBox(height: 16),
              _buildFinishButton(viewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupingArea() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Stack(
        children: _groupItems.map((item) => _buildDraggableGroupItem(item)).toList(),
      ),
    );
  }

  Widget _buildDraggableGroupItem(GroupItem item) {
    return Positioned(
      left: item.position.dx,
      top: item.position.dy,
      child: Draggable<GroupItem>(
        data: item,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: _buildGroupCard(item, isDragging: true),
        ),
        childWhenDragging: Container(
          width: 180,
          height: _calculateHeight(item),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
          ),
        ),
        onDragEnd: (details) {
          setState(() {
            final index = _groupItems.indexOf(item);
            if (index != -1) {
              _groupItems[index] = item.copyWith(
                position: Offset(
                  details.offset.dx.clamp(0, double.infinity),
                  details.offset.dy.clamp(0, double.infinity),
                ),
              );
            }
          });
        },
        child: DragTarget<GroupItem>(
          onWillAccept: (draggedItem) => draggedItem != null && draggedItem != item,
          onAccept: (draggedItem) {
            _mergeGroups(item, draggedItem);
          },
          builder: (context, candidateData, rejectedData) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: candidateData.isNotEmpty
                    ? Border.all(color: Colors.blue, width: 3)
                    : null,
              ),
              child: _buildGroupCard(item, isHovered: candidateData.isNotEmpty),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupCard(GroupItem item, {bool isDragging = false, bool isHovered = false}) {
    final color = isHovered ? Colors.blue.shade50 : Colors.white;
    
    return Container(
      width: 180,
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHovered ? Colors.blue : Colors.grey.shade300,
          width: isHovered ? 2 : 1,
        ),
        boxShadow: isDragging ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showRenameDialog(item),
                    child: Text(
                      _getGroupName(item),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${item.thoughts.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: item.thoughts.take(3).map((thought) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(thought.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getCategoryColor(thought.category).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    thought.content,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
              ),
            ),
            if (item.thoughts.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${item.thoughts.length - 3} more...',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton(RetroViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _groupItems.isNotEmpty ? () => _finishGrouping(viewModel) : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('Finish Grouping (${_groupItems.length} groups)'),
      ),
    );
  }

  double _calculateHeight(GroupItem item) {
    return 100 + (item.thoughts.length.clamp(0, 3) * 30).toDouble();
  }

  String _getGroupName(GroupItem item) {
    if (item.customName?.isNotEmpty == true) {
      return item.customName!;
    }
    if (item.thoughts.length == 1) {
      return 'Single Item';
    }
    return 'Group (${item.thoughts.length} items)';
  }

  void _mergeGroups(GroupItem target, GroupItem source) {
    setState(() {
      final targetIndex = _groupItems.indexOf(target);
      if (targetIndex != -1) {
        // Merge thoughts
        final mergedThoughts = [...target.thoughts, ...source.thoughts];
        _groupItems[targetIndex] = target.copyWith(thoughts: mergedThoughts);
        
        // Remove source group
        _groupItems.remove(source);
      }
    });
  }

  void _showRenameDialog(GroupItem item) {
    final controller = TextEditingController(text: item.customName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = _groupItems.indexOf(item);
                if (index != -1) {
                  _groupItems[index] = item.copyWith(customName: controller.text.trim());
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishGrouping(RetroViewModel viewModel) async {
    try {
      // Clear existing groups
      await viewModel.clearGroups();
      
      // Create groups from current items
      for (int i = 0; i < _groupItems.length; i++) {
        final item = _groupItems[i];
        final group = ThoughtGroup(
          id: '', // Firebase will generate
          name: _getGroupName(item),
          thoughts: item.thoughts,
          sessionId: viewModel.currentSessionId ?? '',
          x: item.position.dx,
          y: item.position.dy,
        );
        
        await viewModel.createGroup(group.name, item.thoughts, item.position.dx, item.position.dy);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created ${_groupItems.length} groups successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating groups: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getCategoryColor(String category) {
    switch (RetroConstants.categoryColors[category]) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class GroupItem {
  final String id;
  final List<RetroThought> thoughts;
  final Offset position;
  final String? customName;

  GroupItem({
    required this.id,
    required this.thoughts,
    required this.position,
    this.customName,
  });

  GroupItem copyWith({
    List<RetroThought>? thoughts,
    Offset? position,
    String? customName,
  }) {
    return GroupItem(
      id: id,
      thoughts: thoughts ?? this.thoughts,
      position: position ?? this.position,
      customName: customName ?? this.customName,
    );
  }
}

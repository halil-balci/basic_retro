import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

class GroupingPhaseWidget extends StatelessWidget {
  const GroupingPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header card similar to editing phase
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.group_work,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grouping Phase',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Drag and drop similar thoughts together to create groups.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Three column layout like editing phase
              Row(
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
                      child: _buildGroupingCategoryColumn(category, categoryColor, viewModel),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupingCategoryColumn(String category, Color color, RetroViewModel viewModel) {
    return Container(
      height: 500, // Fixed height for better drag-drop experience
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
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
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  RetroConstants.categoryTitles[category] ?? category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Drop target area for grouping
          Expanded(
            child: DragTarget<RetroThought>(
              onWillAccept: (data) {
                return data != null;
              },
              onAccept: (thought) {
                _moveThoughtToCategory(thought, category, viewModel);
              },
              builder: (context, candidateData, rejectedData) {
                final isHighlighted = candidateData.isNotEmpty;
                return Container(
                  padding: const EdgeInsets.all(16),
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: _buildDraggableThoughtsList(category, viewModel),
                    ),
                  ),
                );
              },
            ),
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
    
    return thoughts
        .map((thought) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _DraggableThoughtCard(
                thought: thought,
                viewModel: viewModel,
              ),
            ))
        .toList();
  }

  void _moveThoughtToCategory(RetroThought thought, String newCategory, RetroViewModel viewModel) {
    // For now, we'll just show a debug print. The actual implementation would update the thought's category
    debugPrint('Moved "${thought.content}" to $newCategory');
  }
}

class _DraggableThoughtCard extends StatelessWidget {
  final RetroThought thought;
  final RetroViewModel viewModel;

  const _DraggableThoughtCard({
    required this.thought,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
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
        child: _buildThoughtCard(),
      ),
      child: _buildThoughtCard(),
    );
  }

  Widget _buildThoughtCard() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          thought.content,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

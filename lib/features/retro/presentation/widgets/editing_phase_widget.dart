import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

class EditingPhaseWidget extends StatefulWidget {
  const EditingPhaseWidget({super.key});

  @override
  State<EditingPhaseWidget> createState() => _EditingPhaseWidgetState();
}

class _EditingPhaseWidgetState extends State<EditingPhaseWidget> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = Map.fromEntries(
      RetroConstants.categories.map((category) => 
        MapEntry(category, TextEditingController())),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
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
                        Icons.edit_rounded,
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
                            'Editing Phase',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Share your thoughts anonymously. Others\' thoughts are hidden until the next phase.',
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
                      child: _buildCategoryColumn(category, categoryColor, viewModel),
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

  Widget _buildCategoryColumn(String category, Color color, RetroViewModel viewModel) {
    return Container(
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
          // Input area
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controllers[category],
              decoration: InputDecoration(
                hintText: RetroConstants.categoryDescriptions[category] ?? 'Add a $category item...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () => _addThought(category, viewModel),
                  ),
                ),
              ),
              onSubmitted: (_) => _addThought(category, viewModel),
              maxLines: null,
            ),
          ),
          // Thoughts list
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              children: _buildThoughtsList(category, viewModel),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'keep':
        return Icons.thumb_up_rounded;
      case 'stop':
        return Icons.thumb_down_rounded;
      case 'start':
        return Icons.lightbulb_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  List<Widget> _buildThoughtsList(String category, RetroViewModel viewModel) {
    final thoughts = viewModel.thoughtsByCategory[category] ?? <RetroThought>[];
    return thoughts
        .map((thought) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _BlurredThoughtCard(
                thought: thought,
                shouldBlur: viewModel.shouldBlurThought(thought),
              ),
            ))
        .toList();
  }

  void _addThought(String category, RetroViewModel viewModel) async {
    final content = _controllers[category]?.text.trim() ?? '';
    if (content.isEmpty) return;

    try {
      await viewModel.addThought(content, category);
      _controllers[category]?.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding thought: $e')),
        );
      }
    }
  }
}

class _BlurredThoughtCard extends StatelessWidget {
  final RetroThought thought;
  final bool shouldBlur;

  const _BlurredThoughtCard({
    required this.thought,
    required this.shouldBlur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: shouldBlur
            ? Stack(
                children: [
                  Text(
                    thought.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.visibility_off_rounded,
                          color: Color(0xFF6B7280),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                thought.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}

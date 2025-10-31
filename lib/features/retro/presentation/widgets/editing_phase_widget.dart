import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

import '../../../../core/presentation/widgets/common/category_column.dart';
import '../../../../core/presentation/widgets/common/thought_input_field.dart';
import '../../../../core/presentation/widgets/common/thought_card.dart';
import '../../../../core/presentation/widgets/base_stateful_phase_widget.dart';

class EditingPhaseWidget extends BaseStatefulPhaseWidget {
  const EditingPhaseWidget({super.key});

  @override
  String get phaseTitle => 'Editing Phase';

  @override
  String get phaseDescription => 'Add your thoughts anonymously';

  @override
  IconData get phaseIcon => Icons.edit;

  @override
  List<Color> get phaseGradientColors => const [Color(0xFF6366F1), Color(0xFF4F46E5)];

  @override
  BaseStatefulPhaseState<EditingPhaseWidget> createState() => _EditingPhaseWidgetState();
}

class _EditingPhaseWidgetState extends BaseStatefulPhaseState<EditingPhaseWidget> {
  late final Map<String, TextEditingController> _controllers;
  final Map<String, bool> _isAdding = {};

  @override
  void initState() {
    super.initState();
    _controllers = Map.fromEntries(
      RetroConstants.categories.map((category) => 
        MapEntry(category, TextEditingController())),
    );
    // Initialize loading states
    for (final category in RetroConstants.categories) {
      _isAdding[category] = false;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget buildPhaseContent(BuildContext context, bool isSmallScreen) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        // Categories - Responsive layout
        return isSmallScreen 
          ? Column(
              children: RetroConstants.categories.map((category) {
                final colorName = RetroConstants.categoryColors[category] ?? 'grey';
                final categoryColor = _getColorFromName(colorName);
                return Container(
                  margin: EdgeInsets.only(
                    bottom: category != RetroConstants.categories.last ? 16 : 0,
                  ),
                  child: _buildCategoryColumn(category, categoryColor, viewModel, isSmallScreen),
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
                    child: _buildCategoryColumn(category, categoryColor, viewModel, isSmallScreen),
                  ),
                );
              }).toList(),
            );
      },
    );
  }

  Widget _buildCategoryColumn(String category, Color color, RetroViewModel viewModel, bool isSmallScreen) {
    return CategoryColumn(
      category: category,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input area using common widget
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: ThoughtInputField(
              controller: _controllers[category]!,
              hintText: RetroConstants.categoryDescriptions[category] ?? 'Add a $category item...',
              color: color,
              onSubmit: () => _addThought(category, viewModel),
              isLoading: _isAdding[category] ?? false,
              isSmallScreen: isSmallScreen,
            ),
          ),
          // Thoughts list
          Padding(
            padding: EdgeInsets.only(
              left: isSmallScreen ? 12 : 16,
              right: isSmallScreen ? 12 : 16,
              bottom: isSmallScreen ? 12 : 16,
            ),
            child: Column(
              children: _buildThoughtsList(category, viewModel, isSmallScreen),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildThoughtsList(String category, RetroViewModel viewModel, bool isSmallScreen) {
    final thoughts = viewModel.thoughtsByCategory[category] ?? <RetroThought>[];
    final colorName = RetroConstants.categoryColors[category] ?? 'grey';
    final categoryColor = _getColorFromName(colorName);
    
    return thoughts
        .map((thought) => Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
              child: ThoughtCard(
                text: thought.content,
                color: categoryColor,
                thought: thought,
                shouldBlur: viewModel.shouldBlurThought(thought),
                canEdit: viewModel.canEditThought(thought),
                onUpdate: (newContent) => viewModel.updateThought(thought, newContent),
                onDelete: () => viewModel.deleteThought(thought),
              ),
            ))
        .toList();
  }

  Color _getColorFromName(String colorName) {
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

  void _addThought(String category, RetroViewModel viewModel) async {
    final content = _controllers[category]?.text.trim() ?? '';
    if (content.isEmpty) return;

    // Prevent multiple submissions
    if (_isAdding[category] == true) return;

    // Set loading state
    setState(() {
      _isAdding[category] = true;
    });

    // Clear the input field immediately for better UX
    _controllers[category]?.clear();
    
    try {
      await viewModel.addThought(content, category);
      // The Firebase listener will automatically update the UI,
      // so no need to manually trigger a rebuild here
    } catch (e) {
      if (mounted) {
        // Show error and restore the content since it failed
        _controllers[category]?.text = content;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding thought: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Clear loading state
      if (mounted) {
        setState(() {
          _isAdding[category] = false;
        });
      }
    }
  }
}


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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isSmallScreen
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Editing Phase',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Share your thoughts anonymously. Others\' thoughts are hidden until the next phase.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      : Row(
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
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  // Categories - Responsive layout
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
                              child: _buildCategoryColumn(category, categoryColor, viewModel, isSmallScreen),
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

  Widget _buildCategoryColumn(String category, Color color, RetroViewModel viewModel, bool isSmallScreen) {
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
          // Input area
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: TextField(
              controller: _controllers[category],
              enabled: !(_isAdding[category] ?? false),
              maxLines: isSmallScreen ? 2 : null,
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              decoration: InputDecoration(
                hintText: RetroConstants.categoryDescriptions[category] ?? 'Add a $category item...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 12,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: (_isAdding[category] ?? false) ? Colors.grey : color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: (_isAdding[category] ?? false)
                      ? SizedBox(
                          width: isSmallScreen ? 20 : 24,
                          height: isSmallScreen ? 20 : 24,
                          child: Center(
                            child: SizedBox(
                              width: isSmallScreen ? 14 : 16,
                              height: isSmallScreen ? 14 : 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.send, 
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 20,
                          ),
                          onPressed: () => _addThought(category, viewModel),
                        ),
                ),
              ),
              onSubmitted: (_) => _addThought(category, viewModel),
            ),
          ),
          // Thoughts list
          Padding(
            padding: EdgeInsets.only(
              left: isSmallScreen ? 12 : 16, 
              right: isSmallScreen ? 12 : 16, 
              bottom: isSmallScreen ? 12 : 16
            ),
            child: Column(
              children: _buildThoughtsList(category, viewModel, isSmallScreen),
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

  List<Widget> _buildThoughtsList(String category, RetroViewModel viewModel, bool isSmallScreen) {
    final thoughts = viewModel.thoughtsByCategory[category] ?? <RetroThought>[];
    return thoughts
        .map((thought) => Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
              child: _BlurredThoughtCard(
                thought: thought,
                shouldBlur: viewModel.shouldBlurThought(thought),
                isSmallScreen: isSmallScreen,
              ),
            ))
        .toList();
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

class _BlurredThoughtCard extends StatelessWidget {
  final RetroThought thought;
  final bool shouldBlur;
  final bool isSmallScreen;

  const _BlurredThoughtCard({
    required this.thought,
    required this.shouldBlur,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
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
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.transparent,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.visibility_off_rounded,
                          color: Color(0xFF6B7280),
                          size: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                thought.content,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Color(0xFF374151),
                  height: 1.4,
                ),
              ),
      ),
    );
  }
}

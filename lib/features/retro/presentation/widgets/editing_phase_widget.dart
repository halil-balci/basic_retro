import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/retro_thought.dart';
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
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
              decoration: InputDecoration(
                hintText: RetroConstants.categoryDescriptions[category] ?? 'Add a $category item...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: isSmallScreen ? 13 : 14,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: 12,
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
                                strokeWidth: 1,
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
              child: _EditableThoughtCard(
                thought: thought,
                shouldBlur: viewModel.shouldBlurThought(thought),
                canEdit: viewModel.canEditThought(thought),
                isSmallScreen: isSmallScreen,
                onUpdate: (newContent) => viewModel.updateThought(thought, newContent),
                onDelete: () => viewModel.deleteThought(thought),
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

class _EditableThoughtCard extends StatefulWidget {
  final RetroThought thought;
  final bool shouldBlur;
  final bool canEdit;
  final bool isSmallScreen;
  final Function(String) onUpdate;
  final Future<void> Function() onDelete;

  const _EditableThoughtCard({
    required this.thought,
    required this.shouldBlur,
    required this.canEdit,
    required this.onUpdate,
    required this.onDelete,
    this.isSmallScreen = false,
  });

  @override
  State<_EditableThoughtCard> createState() => _EditableThoughtCardState();
}

class _EditableThoughtCardState extends State<_EditableThoughtCard> {
  bool _isEditing = false;
  bool _isUpdating = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.thought.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isSmallScreen ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isEditing ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: widget.shouldBlur
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: widget.isSmallScreen ? 12 : 16,
                  horizontal: widget.isSmallScreen ? 8 : 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_off_rounded,
                        color: Color(0xFF6B7280),
                        size: widget.isSmallScreen ? 20 : 24,
                      )
                    ],
                  ),
                ),
              )
            : _isEditing
                ? Column(
                    children: [
                      TextField(
                        controller: _controller,
                        enabled: !_isUpdating,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: widget.isSmallScreen ? 13 : 14,
                          color: const Color(0xFF374151),
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _saveEdit(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isUpdating ? null : _cancelEdit,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6B7280),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(fontSize: widget.isSmallScreen ? 12 : 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isUpdating ? null : _saveEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            child: _isUpdating
                                ? SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Save',
                                    style: TextStyle(fontSize: widget.isSmallScreen ? 12 : 14),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.thought.content,
                          style: TextStyle(
                            fontSize: widget.isSmallScreen ? 13 : 14,
                            color: const Color(0xFF374151),
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (widget.canEdit) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _startEdit,
                          icon: Icon(
                            Icons.edit_rounded,
                            size: widget.isSmallScreen ? 16 : 18,
                            color: const Color(0xFF6B7280),
                          ),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          tooltip: 'Edit thought',
                        ),
                        IconButton(
                          onPressed: _confirmDelete,
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: widget.isSmallScreen ? 16 : 18,
                            color: const Color(0xFFEF4444),
                          ),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          tooltip: 'Delete thought',
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.thought.content;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.thought.content;
    });
  }

  void _saveEdit() async {
    final newContent = _controller.text.trim();
    if (newContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thought cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newContent == widget.thought.content) {
      _cancelEdit();
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await widget.onUpdate(newContent);
      setState(() {
        _isEditing = false;
        _isUpdating = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating thought: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thought'),
        content: const Text('Are you sure you want to delete this thought? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.onDelete();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting thought: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}


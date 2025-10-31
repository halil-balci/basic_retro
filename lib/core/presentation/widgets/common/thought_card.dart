import 'package:flutter/material.dart';
import '../../mixins/responsive_mixin.dart';
import '../../../../features/retro/domain/entities/retro_thought.dart';

/// Common thought card widget with optional edit/delete capabilities
/// Follows Single Responsibility Principle - handles thought display and editing
class ThoughtCard extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isHighlighted;
  
  // Edit/Delete functionality (optional)
  final RetroThought? thought;
  final bool shouldBlur;
  final bool canEdit;
  final Function(String)? onUpdate;
  final Future<void> Function()? onDelete;

  const ThoughtCard({
    super.key,
    required this.text,
    required this.color,
    this.onTap,
    this.trailing,
    this.isHighlighted = false,
    this.thought,
    this.shouldBlur = false,
    this.canEdit = false,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends State<ThoughtCard> with ResponsiveMixin {
  bool _isEditing = false;
  bool _isUpdating = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = isSmallScreen(context);

    // Simple display mode (no edit/delete)
    if (!widget.canEdit && !widget.shouldBlur) {
      return _buildSimpleCard(context, isSmall);
    }

    // Editable mode
    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 12),
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
            ? _buildBlurredContent(isSmall)
            : _isEditing
                ? _buildEditMode(isSmall)
                : _buildDisplayMode(isSmall),
      ),
    );
  }

  Widget _buildSimpleCard(BuildContext context, bool isSmall) {
    return Card(
      elevation: widget.isHighlighted ? 8 : 2,
      color: widget.isHighlighted ? widget.color.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getResponsiveBorderRadius(context)),
        side: BorderSide(
          color: widget.isHighlighted ? widget.color : widget.color.withOpacity(0.2),
          width: widget.isHighlighted ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(getResponsiveBorderRadius(context)),
        child: Padding(
          padding: EdgeInsets.all(getResponsivePadding(context, small: 12, large: 16)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, small: 13, large: 15),
                    color: Colors.grey[800],
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                SizedBox(width: getResponsiveSpacing(context)),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurredContent(bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 12 : 16,
        horizontal: isSmall ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF6B7280).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(
          Icons.visibility_off_rounded,
          color: const Color(0xFF6B7280),
          size: isSmall ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildEditMode(bool isSmall) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          enabled: !_isUpdating,
          minLines: 1,
          maxLines: 5,
          style: TextStyle(
            fontSize: isSmall ? 13 : 14,
            color: const Color(0xFF374151),
            height: 1.4,
          ),
          decoration: const InputDecoration(
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
                style: TextStyle(fontSize: isSmall ? 12 : 14),
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
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(fontSize: isSmall ? 12 : 14),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDisplayMode(bool isSmall) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
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
              size: isSmall ? 16 : 18,
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
              size: isSmall ? 16 : 18,
              color: const Color(0xFFEF4444),
            ),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            tooltip: 'Delete thought',
          ),
        ],
      ],
    );
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
      _controller.text = widget.text;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.text;
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

    if (newContent == widget.text) {
      _cancelEdit();
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      if (widget.onUpdate != null) {
        await widget.onUpdate!(newContent);
      }
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isUpdating = false;
        });
      }
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
        if (widget.onDelete != null) {
          await widget.onDelete!();
        }
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

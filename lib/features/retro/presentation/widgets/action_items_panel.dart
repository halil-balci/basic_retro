import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/action_item.dart';
import '../retro_view_model.dart';
import '../../../../services/action_item_export_service.dart';

class ActionItemsPanel extends StatefulWidget {
  final bool isSmallScreen;

  const ActionItemsPanel({
    super.key,
    this.isSmallScreen = false,
  });

  @override
  State<ActionItemsPanel> createState() => _ActionItemsPanelState();
}

class _ActionItemsPanelState extends State<ActionItemsPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = true;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  bool _isAdding = false;
  DateTime? _lastAIRequestTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        // Tüm session için action items (grup bazlı değil)
        final actionItems = viewModel.actionItems;

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(
            horizontal: widget.isSmallScreen ? 12 : 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              InkWell(
                onTap: _toggleExpanded,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  padding: EdgeInsets.all(widget.isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(widget.isSmallScreen ? 6 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.checklist_rounded,
                          color: Colors.white,
                          size: widget.isSmallScreen ? 18 : 22,
                        ),
                      ),
                      SizedBox(width: widget.isSmallScreen ? 10 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Action Items',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${actionItems.length} item${actionItems.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: widget.isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => _exportActionItems(viewModel),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.all(widget.isSmallScreen ? 6 : 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: widget.isSmallScreen ? 18 : 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: widget.isSmallScreen ? 20 : 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Padding(
                  padding: EdgeInsets.all(widget.isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Add new action item
                      Container(
                        padding: EdgeInsets.all(widget.isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _contentController,
                                enabled: !_isAdding,
                                maxLines: null,
                                style: TextStyle(fontSize: widget.isSmallScreen ? 13 : 14),
                                decoration: InputDecoration(
                                  hintText: 'What action should be taken?',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: widget.isSmallScreen ? 12 : 13,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12,vertical: 10,),
                                ),
                                onSubmitted: (_) => _addActionItem(viewModel),
                              ),
                              SizedBox(height: widget.isSmallScreen ? 8 : 10),
                              TextField(
                                controller: _assigneeController,
                                enabled: !_isAdding,
                                style: TextStyle(fontSize: widget.isSmallScreen ? 13 : 14),
                                decoration: InputDecoration(
                                  hintText: 'Assignee (optional)',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: widget.isSmallScreen ? 12 : 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    size: widget.isSmallScreen ? 16 : 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              SizedBox(height: widget.isSmallScreen ? 8 : 10),
                              // AI Generate Button
                              OutlinedButton.icon(
                                onPressed: viewModel.isGeneratingActionItem || _isAdding
                                    ? null
                                    : () => _showAIGenerateDialog(context, viewModel),
                                icon: viewModel.isGeneratingActionItem
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            const Color(0xFF6366F1),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.auto_awesome,
                                        size: widget.isSmallScreen ? 16 : 18,
                                      ),
                                label: Text(
                                  'Generate with AI',
                                  style: TextStyle(fontSize: widget.isSmallScreen ? 12 : 14),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6366F1),
                                  side: const BorderSide(color: Color(0xFF6366F1)),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: widget.isSmallScreen ? 12 : 16,
                                    vertical: widget.isSmallScreen ? 8 : 12,
                                  ),
                                ),
                              ),
                              SizedBox(height: widget.isSmallScreen ? 8 : 10),
                              ElevatedButton.icon(
                                onPressed: _isAdding ? null : () => _addActionItem(viewModel),
                                icon: _isAdding
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Icon(
                                        Icons.add_circle_outline,
                                        size: widget.isSmallScreen ? 16 : 18,
                                      ),
                                label: Text(
                                  'Add Action Item',
                                  style: TextStyle(fontSize: widget.isSmallScreen ? 12 : 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: widget.isSmallScreen ? 12 : 16,
                                  vertical: widget.isSmallScreen ? 8 : 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (actionItems.isNotEmpty) ...[
                        SizedBox(height: widget.isSmallScreen ? 12 : 16),
                        Text(
                          'Current Actions:',
                          style: TextStyle(
                            fontSize: widget.isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                        SizedBox(height: widget.isSmallScreen ? 8 : 10),
                        ...actionItems.map((item) => _ActionItemCard(
                              actionItem: item,
                              isSmallScreen: widget.isSmallScreen,
                              onUpdate: (updated) => viewModel.updateActionItem(updated),
                              onDelete: () => viewModel.deleteActionItem(item.id),
                              canEdit: true, // Tüm kullanıcılar düzenleyebilir
                            )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addActionItem(RetroViewModel viewModel) async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isAdding = true;
    });

    try {
      final assignee = _assigneeController.text.trim();
      await viewModel.addActionItem(
        content,
        assignee: assignee.isNotEmpty ? assignee : null,
      );
      _contentController.clear();
      _assigneeController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding action item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  Future<void> _showAIGenerateDialog(BuildContext context, RetroViewModel viewModel) async {
    // Check cooldown (minimum 5 seconds between requests)
    if (_lastAIRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastAIRequestTime!);
      if (timeSinceLastRequest.inSeconds < 5) {
        final remainingSeconds = 5 - timeSinceLastRequest.inSeconds;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please wait $remainingSeconds more second(s) before generating again.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    _lastAIRequestTime = DateTime.now();

    try {
      // Generate action item
      await viewModel.generateActionItemFromCurrentGroup();

      if (!mounted) return;

      // Show dialog with result
      if (viewModel.generatedActionItem != null) {
        _showGeneratedActionItemDialog(context, viewModel);
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating action item: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showGeneratedActionItemDialog(BuildContext context, RetroViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500, // Maksimum genişlik sınırı
            minWidth: 300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'AI Generated Action Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Content
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    viewModel.generatedActionItem ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        viewModel.clearGeneratedActionItem();
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Set to input field
                        _contentController.text = viewModel.generatedActionItem ?? '';
                        viewModel.clearGeneratedActionItem();
                        Navigator.of(dialogContext).pop();
                        
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Action item added to input field'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Use This',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportActionItems(RetroViewModel viewModel) {
    if (viewModel.currentSession == null) return;

    try {
      ActionItemExportService.exportToText(
        actionItems: viewModel.actionItems,
        groups: viewModel.currentGroups,
        session: viewModel.currentSession!,
      );
    } catch (e) {
      debugPrint('Error exporting action items: $e');
    }
  }
}

class _ActionItemCard extends StatefulWidget {
  final ActionItem actionItem;
  final bool isSmallScreen;
  final Function(ActionItem) onUpdate;
  final VoidCallback onDelete;
  final bool canEdit;

  const _ActionItemCard({
    required this.actionItem,
    required this.isSmallScreen,
    required this.onUpdate,
    required this.onDelete,
    required this.canEdit,
  });

  @override
  State<_ActionItemCard> createState() => _ActionItemCardState();
}

class _ActionItemCardState extends State<_ActionItemCard> {
  bool _isEditing = false;
  late TextEditingController _contentController;
  late TextEditingController _assigneeController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.actionItem.content);
    _assigneeController = TextEditingController(text: widget.actionItem.assignee ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isEditing
              ? const Color(0xFF6366F1)
              : const Color(0xFFE2E8F0),
          width: _isEditing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(widget.isSmallScreen ? 10 : 12),
            child: _isEditing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _contentController,
                        enabled: !_isUpdating,
                        maxLines: null,
                        style: TextStyle(fontSize: widget.isSmallScreen ? 13 : 14),
                        decoration: InputDecoration(
                          hintText: 'Action item content',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      SizedBox(height: widget.isSmallScreen ? 6 : 8),
                      TextField(
                        controller: _assigneeController,
                        enabled: !_isUpdating,
                        style: TextStyle(fontSize: widget.isSmallScreen ? 13 : 14),
                        decoration: InputDecoration(
                          hintText: 'Assignee (optional)',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            size: widget.isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(height: widget.isSmallScreen ? 8 : 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isUpdating ? null : _cancelEdit,
                            child: Text(
                              'Cancel',
                              style: TextStyle(fontSize: widget.isSmallScreen ? 11 : 12),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isUpdating ? null : _saveEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              padding: EdgeInsets.symmetric(
                                horizontal: widget.isSmallScreen ? 10 : 12,
                                vertical: widget.isSmallScreen ? 6 : 8,
                              ),
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
                                    style: TextStyle(fontSize: widget.isSmallScreen ? 11 : 12),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.actionItem.content,
                              style: TextStyle(
                                fontSize: widget.isSmallScreen ? 13 : 14,
                                color: const Color(0xFF374151),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.actionItem.assignee != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: widget.isSmallScreen ? 12 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.actionItem.assignee!,
                                    style: TextStyle(
                                      fontSize: widget.isSmallScreen ? 11 : 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.canEdit) ...[
                        IconButton(
                          onPressed: _startEdit,
                          icon: Icon(
                            Icons.edit_outlined,
                            size: widget.isSmallScreen ? 16 : 18,
                            color: Colors.grey.shade600,
                          ),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          onPressed: _confirmDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            size: widget.isSmallScreen ? 16 : 18,
                            color: const Color(0xFFEF4444),
                          ),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          tooltip: 'Delete',
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _startEdit() {
    setState(() {
      _isEditing = true;
      _contentController.text = widget.actionItem.content;
      _assigneeController.text = widget.actionItem.assignee ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _contentController.text = widget.actionItem.content;
      _assigneeController.text = widget.actionItem.assignee ?? '';
    });
  }

  Future<void> _saveEdit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action item cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final assignee = _assigneeController.text.trim();
      final updated = widget.actionItem.copyWith(
        content: content,
        assignee: assignee.isNotEmpty ? assignee : null,
      );
      await widget.onUpdate(updated);
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
            content: Text('Error updating action item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Action Item'),
        content: const Text('Are you sure you want to delete this action item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        widget.onDelete();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting action item: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

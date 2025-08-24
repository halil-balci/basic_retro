import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/retro_phase.dart';
import 'retro_view_model.dart';
import 'widgets/editing_phase_widget.dart';
import 'widgets/grouping_phase_widget.dart';
import 'widgets/voting_phase_widget.dart';
import 'widgets/discuss_phase_widget.dart';
import '../../../core/constants/retro_constants.dart';

class RetroBoardView extends StatefulWidget {
  final String sessionId;

  const RetroBoardView({
    super.key,
    required this.sessionId,
  });

  @override
  State<RetroBoardView> createState() => _RetroBoardViewState();
}

class _RetroBoardViewState extends State<RetroBoardView> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<RetroViewModel>();
    viewModel.selectSession(widget.sessionId);
  }

  @override
  void dispose() {
    final viewModel = context.read<RetroViewModel>();
    // Make sure to leave the session and clean up
    if (viewModel.currentSessionId != null) {
      viewModel.leaveSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentSession == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            title: Row(
              children: [
                Icon(
                  Icons.dashboard_rounded,
                  color: const Color(0xFF4F46E5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.currentSession?.name ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 16),
                _buildActiveUsers(viewModel),
                const Spacer(),
                _buildPhaseIndicator(viewModel),
              ],
            ),
            actions: [
              if (viewModel.canAdvancePhase)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdvancePhaseConfirmation(viewModel),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      'Next: ${viewModel.currentSession!.nextPhase.displayName}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPhaseColor(viewModel.currentSession!.nextPhase),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: _getAdvanceRequirement(viewModel.currentPhase),
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text('Next: ${viewModel.currentSession!.nextPhase.displayName}'),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Session ID: ${widget.sessionId}'),
                      action: SnackBarAction(
                        label: 'Copy',
                        onPressed: () {
                          // TODO: Add clipboard functionality
                        },
                      ),
                    ),
                  );
                },
                tooltip: 'Share session',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildPhaseContent(viewModel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveUsers(RetroViewModel viewModel) {
    final activeUsers = viewModel.currentSession?.activeUsers ?? {};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_rounded,
            size: 14,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 4),
          Text(
            '${activeUsers.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(RetroViewModel viewModel) {
    final phase = viewModel.currentPhase;
    final phaseColor = _getPhaseColor(phase);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.1),
        border: Border.all(color: phaseColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPhaseIcon(phase),
            size: 14,
            color: phaseColor,
          ),
          const SizedBox(width: 6),
          Text(
            phase.displayName,
            style: TextStyle(
              color: phaseColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent(RetroViewModel viewModel) {
    switch (viewModel.currentPhase) {
      case RetroPhase.editing:
        return const EditingPhaseWidget();
      case RetroPhase.grouping:
        return const GroupingPhaseWidget();
      case RetroPhase.voting:
        return const VotingPhaseWidget();
      case RetroPhase.discuss:
        return const DiscussPhaseWidget();
    }
  }

  Color _getPhaseColor(RetroPhase phase) {
    switch (phase) {
      case RetroPhase.editing:
        return const Color(0xFF10B981); // Green
      case RetroPhase.grouping:
        return const Color(0xFF3B82F6); // Blue
      case RetroPhase.voting:
        return const Color(0xFF8B5CF6); // Purple
      case RetroPhase.discuss:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  String _getAdvanceRequirement(RetroPhase currentPhase) {
    switch (currentPhase) {
      case RetroPhase.editing:
        return 'Add at least one thought to advance';
      case RetroPhase.grouping:
        return 'Create at least one group to advance';
      case RetroPhase.voting:
        return 'At least one group must have votes to advance';
      case RetroPhase.discuss:
        return 'This is the final phase';
    }
  }

  void _showAdvancePhaseConfirmation(RetroViewModel viewModel) {
    final nextPhase = viewModel.currentSession!.nextPhase;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getPhaseIcon(nextPhase), color: _getPhaseColor(nextPhase)),
            const SizedBox(width: 8),
            Text('Advance to ${nextPhase.displayName}?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to advance from ${viewModel.currentPhase.displayName} to ${nextPhase.displayName} phase.'),
            const SizedBox(height: 16),
            Text(
              nextPhase.description,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This action cannot be undone. All participants will see the new phase.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _advancePhase(viewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPhaseColor(nextPhase),
              foregroundColor: Colors.white,
            ),
            child: Text('Advance to ${nextPhase.displayName}'),
          ),
        ],
      ),
    );
  }

  IconData _getPhaseIcon(RetroPhase phase) {
    switch (phase) {
      case RetroPhase.editing:
        return Icons.edit_rounded;
      case RetroPhase.grouping:
        return Icons.group_work_rounded;
      case RetroPhase.voting:
        return Icons.how_to_vote_rounded;
      case RetroPhase.discuss:
        return Icons.forum_rounded;
    }
  }

  void _advancePhase(RetroViewModel viewModel) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Advancing to next phase...'),
            ],
          ),
        ),
      );

      await viewModel.advancePhase();
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        final nextPhase = viewModel.currentPhase;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Advanced to ${nextPhase.displayName} phase!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error advancing phase: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

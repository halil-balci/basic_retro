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
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  'Retro: ${viewModel.currentSession?.name ?? ""}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                _buildActiveUsers(viewModel),
                const SizedBox(width: 16),
                _buildPhaseIndicator(viewModel),
              ],
            ),
            actions: [
              if (viewModel.canAdvancePhase)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAdvancePhaseConfirmation(viewModel),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text('Next: ${viewModel.currentSession!.nextPhase.displayName}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getPhaseColor(viewModel.currentSession!.nextPhase),
                      foregroundColor: Colors.white,
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
              // Debug Phase Info (remove in production)
              if (true) // Set to false in production
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: Consumer<RetroViewModel>(
                    builder: (context, viewModel, child) {
                      return Text(
                        'Current Phase: ${viewModel.currentPhase.displayName} | '
                        'Thoughts: ${viewModel.thoughtsByCategory.values.expand((x) => x).length} | '
                        'Groups: ${viewModel.currentGroups.length} | '
                        'Can Advance: ${viewModel.canAdvancePhase}',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.person, size: 16),
        const SizedBox(width: 4),
        Text('${activeUsers.length} active'),
        const SizedBox(width: 8),
        if (activeUsers.isNotEmpty)
          Tooltip(
            message: activeUsers.values.join(', '),
            child: const Icon(Icons.info_outline, size: 16),
          ),
      ],
    );
  }

  Widget _buildPhaseIndicator(RetroViewModel viewModel) {
    final phase = viewModel.currentPhase;
    Color phaseColor;
    
    switch (phase) {
      case RetroPhase.editing:
        phaseColor = Colors.amber;
        break;
      case RetroPhase.grouping:
        phaseColor = Colors.orange;
        break;
      case RetroPhase.voting:
        phaseColor = Colors.purple;
        break;
      case RetroPhase.discuss:
        phaseColor = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: phaseColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        phase.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
        return Colors.amber;
      case RetroPhase.grouping:
        return Colors.orange;
      case RetroPhase.voting:
        return Colors.purple;
      case RetroPhase.discuss:
        return Colors.teal;
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
        return Icons.edit;
      case RetroPhase.grouping:
        return Icons.group_work;
      case RetroPhase.voting:
        return Icons.how_to_vote;
      case RetroPhase.discuss:
        return Icons.forum;
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

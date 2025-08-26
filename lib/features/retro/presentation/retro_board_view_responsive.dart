import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/retro_phase.dart';
import 'retro_view_model.dart';
import 'widgets/editing_phase_widget.dart';
import 'widgets/grouping_phase_widget.dart';
import 'widgets/voting_phase_widget.dart';
import 'widgets/discuss_phase_widget.dart';
import 'widgets/finish_phase_widget.dart';

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

        final isDiscussPhase = viewModel.currentPhase == RetroPhase.discuss;
        final sortedGroups = viewModel.sortedGroupsByVotes;
        final currentIndex = viewModel.currentSession?.currentDiscussionGroupIndex ?? 0;
        final isLastGroup = isDiscussPhase && currentIndex == sortedGroups.length - 1 && sortedGroups.isNotEmpty;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: _buildAppBar(viewModel, isSmallScreen, isDiscussPhase, isLastGroup),
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
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    RetroViewModel viewModel, 
    bool isSmallScreen, 
    bool isDiscussPhase, 
    bool isLastGroup
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      toolbarHeight: isSmallScreen ? 64 : 56,
      title: isSmallScreen 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.dashboard_rounded,
                    color: const Color(0xFF4F46E5),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      viewModel.currentSession?.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _buildActiveUsers(viewModel, isSmallScreen),
                  const SizedBox(width: 8),
                  _buildPhaseIndicator(viewModel, isSmallScreen),
                ],
              ),
            ],
          )
        : Row(
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
              _buildActiveUsers(viewModel, isSmallScreen),
              const Spacer(),
              _buildPhaseIndicator(viewModel, isSmallScreen),
            ],
          ),
      actions: isSmallScreen 
        ? [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'copy') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Session ID: ${widget.sessionId}')),
                  );
                } else if (value == 'next' && viewModel.canAdvancePhase) {
                  _showAdvancePhaseConfirmation(viewModel);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'copy',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 16),
                      SizedBox(width: 8),
                      Text('Share Session'),
                    ],
                  ),
                ),
                if (viewModel.canAdvancePhase)
                  PopupMenuItem(
                    value: 'next',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_forward, size: 16),
                        SizedBox(width: 8),
                        Text('Next: ${viewModel.currentSession!.nextPhase.displayName}'),
                      ],
                    ),
                  ),
              ],
            ),
          ]
        : [
            if (isDiscussPhase && isLastGroup && viewModel.canAdvancePhase)
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
            else if (viewModel.canAdvancePhase)
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
    );
  }

  Widget _buildActiveUsers(RetroViewModel viewModel, bool isSmallScreen) {
    final activeUsers = viewModel.currentSession?.activeUsers ?? {};
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 10, 
        vertical: isSmallScreen ? 2 : 4
      ),
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
            size: isSmallScreen ? 12 : 14,
            color: const Color(0xFF10B981),
          ),
          SizedBox(width: isSmallScreen ? 2 : 4),
          Text(
            '${activeUsers.length}',
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(RetroViewModel viewModel, bool isSmallScreen) {
    final phase = viewModel.currentPhase;
    final phaseColor = _getPhaseColor(phase);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8, 
        vertical: isSmallScreen ? 2 : 4
      ),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPhaseIcon(phase),
            size: isSmallScreen ? 12 : 14,
            color: phaseColor,
          ),
          SizedBox(width: isSmallScreen ? 3 : 4),
          Text(
            phase.displayName,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: phaseColor,
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
      case RetroPhase.finish:
        return const FinishPhaseWidget();
      }
  }

  Color _getPhaseColor(RetroPhase phase) {
    switch (phase) {
      case RetroPhase.editing:
        return const Color(0xFF10B981);
      case RetroPhase.grouping:
        return const Color(0xFF8B5CF6);
      case RetroPhase.voting:
        return const Color(0xFFF59E0B);
      case RetroPhase.discuss:
        return const Color(0xFF059669);
      case RetroPhase.finish:
        return const Color(0xFF6366F1);
      }
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
      case RetroPhase.finish:
        return Icons.flag_rounded;
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
        content: Text(
          nextPhase == RetroPhase.finish 
            ? 'This will end the retro session and show feedback results.'
            : 'This will move all participants to the ${nextPhase.displayName.toLowerCase()} phase.',
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

  void _advancePhase(RetroViewModel viewModel) async {
    try {
      await viewModel.advancePhase();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error advancing phase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

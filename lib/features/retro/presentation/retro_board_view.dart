import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../domain/entities/retro_phase.dart';
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
    if (viewModel.currentSessionId != null) {
      viewModel.leaveSession();
    }
    super.dispose();
  }

  /// Build the shareable URL for the current session
  String _buildShareUrl() {
    final viewModel = context.read<RetroViewModel>();
    final sessionName = viewModel.currentSession?.name ?? widget.sessionId;
    final encodedName = Uri.encodeComponent(sessionName);
    final baseUrl = Uri.base.origin;
    return '$baseUrl/#/$encodedName';
  }

  void _shareSession() {
    final url = _buildShareUrl();
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Session link copied to clipboard!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentSession == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF6366F1)),
                  const SizedBox(height: 16),
                  Text(
                    'Loading session...',
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;

            return Scaffold(
              backgroundColor: const Color(0xFFF1F5F9),
              appBar: _buildAppBar(viewModel, isSmall),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                    : _buildPhaseContent(viewModel),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(RetroViewModel viewModel, bool isSmall) {
    final isDiscussPhase = viewModel.currentPhase == RetroPhase.discuss;
    final sortedGroups = viewModel.sortedGroupsByVotes;
    final currentIndex = viewModel.currentSession?.currentDiscussionGroupIndex ?? 0;
    final isLastGroup = isDiscussPhase && currentIndex == sortedGroups.length - 1 && sortedGroups.isNotEmpty;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0F172A),
      surfaceTintColor: Colors.transparent,
      toolbarHeight: isSmall ? 64 : 60,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: const Color(0xFFE2E8F0),
        ),
      ),
      title: isSmall
          ? _buildMobileTitle(viewModel)
          : _buildDesktopTitle(viewModel),
      actions: isSmall
          ? _buildMobileActions(viewModel)
          : _buildDesktopActions(viewModel, isDiscussPhase, isLastGroup),
    );
  }

  Widget _buildMobileTitle(RetroViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                viewModel.currentSession?.name ?? "",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildActiveUsers(viewModel, true),
            const SizedBox(width: 6),
            _buildPhaseIndicator(viewModel, true),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopTitle(RetroViewModel viewModel) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          viewModel.currentSession?.name ?? "",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 16),
        _buildActiveUsers(viewModel, false),
        const SizedBox(width: 8),
        _buildPhaseIndicator(viewModel, false),
      ],
    );
  }

  List<Widget> _buildMobileActions(RetroViewModel viewModel) {
    return [
      PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF475569)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, 48),
        onSelected: (value) {
          if (value == 'share') {
            _shareSession();
          } else if (value == 'next' && viewModel.canAdvancePhase) {
            _showAdvancePhaseConfirmation(viewModel);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_rounded, size: 18, color: const Color(0xFF6366F1)),
                const SizedBox(width: 10),
                Text('Share Session', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (viewModel.canAdvancePhase)
            PopupMenuItem(
              value: 'next',
              child: Row(
                children: [
                  Icon(Icons.arrow_forward_rounded, size: 18, color: _getPhaseColor(viewModel.currentSession!.nextPhase)),
                  const SizedBox(width: 10),
                  Text('Next: ${viewModel.currentSession!.nextPhase.displayName}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
        ],
      ),
    ];
  }

  List<Widget> _buildDesktopActions(RetroViewModel viewModel, bool isDiscussPhase, bool isLastGroup) {
    return [
      // Share button
      _buildActionButton(
        icon: Icons.share_rounded,
        label: 'Share',
        color: const Color(0xFF6366F1),
        onTap: _shareSession,
        isFilled: false,
      ),
      const SizedBox(width: 8),
      // Advance phase button
      if (viewModel.canAdvancePhase) ...[
        _buildActionButton(
          icon: Icons.arrow_forward_rounded,
          label: 'Next: ${viewModel.currentSession!.nextPhase.displayName}',
          color: _getPhaseColor(viewModel.currentSession!.nextPhase),
          onTap: () => _showAdvancePhaseConfirmation(viewModel),
          isFilled: true,
        ),
        const SizedBox(width: 12),
      ],
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isFilled,
  }) {
    return Material(
      color: isFilled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isFilled ? null : Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isFilled ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isFilled ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveUsers(RetroViewModel viewModel, bool isSmall) {
    final activeUsers = viewModel.currentSession?.activeUsers ?? {};
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_alt_rounded,
            size: isSmall ? 12 : 14,
            color: const Color(0xFF10B981),
          ),
          SizedBox(width: isSmall ? 4 : 5),
          Text(
            '${activeUsers.length} online',
            style: GoogleFonts.inter(
              fontSize: isSmall ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(RetroViewModel viewModel, bool isSmall) {
    final phase = viewModel.currentPhase;
    final phaseColor = _getPhaseColor(phase);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: phaseColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: phaseColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPhaseIcon(phase),
            size: isSmall ? 11 : 13,
            color: phaseColor,
          ),
          SizedBox(width: isSmall ? 4 : 5),
          Text(
            phase.displayName,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 10 : 11,
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
        return const Color(0xFF6366F1);
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
        return Icons.workspaces_rounded;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getPhaseColor(nextPhase).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getPhaseIcon(nextPhase), color: _getPhaseColor(nextPhase), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Advance to ${nextPhase.displayName}?',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Text(
          nextPhase == RetroPhase.finish
              ? 'This will end the retro session and show feedback results.'
              : 'This will move all participants to the ${nextPhase.displayName.toLowerCase()} phase.',
          style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _advancePhase(viewModel);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getPhaseColor(nextPhase),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Advance',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
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
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

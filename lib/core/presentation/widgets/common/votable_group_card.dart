import 'package:flutter/material.dart';
import '../../../../features/retro/domain/entities/thought_group.dart';
import '../../../../features/retro/domain/entities/retro_thought.dart';
import '../../../../features/retro/presentation/retro_view_model.dart';

/// Common votable group card widget for voting phase
/// Displays a group with voting functionality
class VotableGroupCard extends StatelessWidget {
  final ThoughtGroup group;
  final RetroViewModel viewModel;
  final String category;
  final VoidCallback? onVote;
  final VoidCallback? onRemoveVote;

  const VotableGroupCard({
    super.key,
    required this.group,
    required this.viewModel,
    required this.category,
    this.onVote,
    this.onRemoveVote,
  });

  @override
  Widget build(BuildContext context) {
    final hasUserVoted = group.hasUserVoted(viewModel.getCurrentUserId());
    final userVoteCount = group.getUserVoteCount(viewModel.getCurrentUserId());
    
    // Group thoughts by category for better display
    final thoughtsByCategory = <String, List<RetroThought>>{};
    for (final thought in group.thoughts) {
      thoughtsByCategory.putIfAbsent(thought.category, () => []).add(thought);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 4,
      child: InkWell(
        onTap: () => _handleGroupTap(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 200, // Maximum height to prevent overflow
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: hasUserVoted ? Colors.green.shade50 : Colors.amber.shade50,
            border: hasUserVoted 
                ? Border.all(color: Colors.green, width: 2)
                : Border.all(color: Colors.amber, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Group header
                Row(
                  children: [
                    Icon(Icons.group_work, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Group (${group.thoughts.length} items)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Show user's own vote and remove option
                    if (hasUserVoted) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$userVoteCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _handleGroupRemoveVote(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.remove_circle,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Show thoughts by category
                ...thoughtsByCategory.entries.map((entry) {
                  final categoryName = entry.key;
                  final categoryThoughts = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category header if more than one category
                        if (thoughtsByCategory.length > 1) ...[
                          Text(
                            '$categoryName:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                        ],
                        // Show thoughts from this category (max 2 per category)
                        ...categoryThoughts.take(2).map((thought) => Padding(
                          padding: EdgeInsets.only(
                            bottom: 4, 
                            left: thoughtsByCategory.length > 1 ? 12 : 0
                          ),
                          child: Text(
                            thought.content,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                        if (categoryThoughts.length > 2)
                          Padding(
                            padding: EdgeInsets.only(left: thoughtsByCategory.length > 1 ? 12 : 0),
                            child: Text(
                              '+${categoryThoughts.length - 2} more...',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGroupTap(BuildContext context) async {
    final remainingVotes = viewModel.getUserRemainingVotes();
    
    if (remainingVotes <= 0) {
      return;
    }

    try {
      await viewModel.voteForGroup(group.id);
      if (onVote != null) onVote!();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error voting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleGroupRemoveVote(BuildContext context) async {
    try {
      await viewModel.removeVoteFromGroup(group.id);
      if (onRemoveVote != null) onRemoveVote!();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing vote: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

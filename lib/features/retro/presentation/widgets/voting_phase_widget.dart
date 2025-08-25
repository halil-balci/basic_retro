import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/retro_thought.dart';
import '../../domain/thought_group.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';

class VotingPhaseWidget extends StatelessWidget {
  const VotingPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header card similar to editing phase
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9333EA), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.how_to_vote,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voting Phase',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You have ${viewModel.getUserRemainingVotes()} votes remaining. Click on thoughts to vote.',
                            style: const TextStyle(
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
              const SizedBox(height: 24),
              // Three column layout like editing phase
              Row(
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
                      child: _buildVotingCategoryColumn(category, categoryColor, viewModel),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVotingCategoryColumn(String category, Color color, RetroViewModel viewModel) {
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
            padding: const EdgeInsets.all(16),
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
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  RetroConstants.categoryTitles[category] ?? category,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Thoughts list for voting
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _buildVotableThoughtsList(category, viewModel),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Start':
        return Icons.lightbulb_rounded;
      case 'Stop':
        return Icons.thumb_down_rounded;
      case 'Continue':
        return Icons.thumb_up_rounded;
      default:
        return Icons.note_rounded;
    }
  }

  List<Widget> _buildVotableThoughtsList(String category, RetroViewModel viewModel) {
    // Get all groups and filter ones that should belong to this category
    final allGroups = viewModel.currentGroups;
    final groupsForCategory = allGroups.where((group) {
      if (group.thoughts.isEmpty) return false;
      
      // Assign group to the category of its first thought
      final primaryCategory = group.thoughts.first.category;
      return primaryCategory == category;
    }).toList();
    
    // Get all thoughts in groups (regardless of category)
    final thoughtsInGroups = allGroups
        .expand((group) => group.thoughts)
        .map((t) => t.id)
        .toSet();
    
    // Get individual thoughts that are not in any group for this category
    final allThoughtsInCategory = viewModel.thoughtsByCategory[category] ?? <RetroThought>[];
    final individualThoughts = allThoughtsInCategory
        .where((thought) => !thoughtsInGroups.contains(thought.id))
        .toList();
    
    final widgets = <Widget>[];
    
    // Add groups assigned to this category
    for (final group in groupsForCategory) {
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: _VotableGroupCard(
          group: group,
          viewModel: viewModel,
          category: category,
        ),
      ));
    }
    
    // Add individual thoughts for this category
    for (final thought in individualThoughts) {
      widgets.add(Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: _VotableThoughtCard(
          thought: thought,
          viewModel: viewModel,
        ),
      ));
    }
    
    return widgets;
  }
}

class _VotableThoughtCard extends StatelessWidget {
  final RetroThought thought;
  final RetroViewModel viewModel;

  const _VotableThoughtCard({
    required this.thought,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    // Get all groups that contain this thought
    final groupsWithThisThought = viewModel.currentGroups
        .where((group) => group.thoughts.any((t) => t.id == thought.id))
        .toList();
    
    final hasUserVoted = groupsWithThisThought.any((group) => group.hasUserVoted(viewModel.getCurrentUserId()));
    final userVoteCount = groupsWithThisThought.fold(0, (sum, group) => sum + group.getUserVoteCount(viewModel.getCurrentUserId()));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleThoughtTap(context, thought, viewModel),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: hasUserVoted ? Colors.green.shade50 : Colors.white,
            border: hasUserVoted 
                ? Border.all(color: Colors.green, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  thought.content,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              // Show user's own vote count and remove vote option
              if (hasUserVoted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You voted ($userVoteCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _handleRemoveVote(context, thought, viewModel),
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
        ),
      ),
    );
  }

  void _handleThoughtTap(BuildContext context, RetroThought thought, RetroViewModel viewModel) async {
    final remainingVotes = viewModel.getUserRemainingVotes();
    
    if (remainingVotes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No votes remaining!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Find a group containing this thought to vote for
      final groupsWithThought = viewModel.currentGroups
          .where((group) => group.thoughts.any((t) => t.id == thought.id))
          .toList();
      
      if (groupsWithThought.isNotEmpty) {
        // Vote for existing group
        await viewModel.voteForGroup(groupsWithThought.first.id);
      } else {
        // Create a single-thought group and vote for it
        await viewModel.createGroup(
          'Single Item: ${thought.content.length > 20 ? '${thought.content.substring(0, 20)}...' : thought.content}',
          [thought],
          0.0,
          0.0,
        );
        
        // Find the newly created group and vote for it
        final newGroups = viewModel.currentGroups
            .where((group) => group.thoughts.any((t) => t.id == thought.id))
            .toList();
        
        if (newGroups.isNotEmpty) {
          await viewModel.voteForGroup(newGroups.first.id);
        }
      }
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

  void _handleRemoveVote(BuildContext context, RetroThought thought, RetroViewModel viewModel) async {
    try {
      // Find groups containing this thought that user has voted for
      final groupsWithThought = viewModel.currentGroups
          .where((group) => 
              group.thoughts.any((t) => t.id == thought.id) && 
              group.hasUserVoted(viewModel.getCurrentUserId()))
          .toList();
      
      if (groupsWithThought.isNotEmpty) {
        await viewModel.removeVoteFromGroup(groupsWithThought.first.id);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vote removed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
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

class _VotableGroupCard extends StatelessWidget {
  final ThoughtGroup group;
  final RetroViewModel viewModel;
  final String category;

  const _VotableGroupCard({
    required this.group,
    required this.viewModel,
    required this.category,
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
        onTap: () => _handleGroupTap(context, group, viewModel),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: hasUserVoted ? Colors.green.shade50 : Colors.amber.shade50,
            border: hasUserVoted 
                ? Border.all(color: Colors.green, width: 2)
                : Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ),
                  // Show user's own vote and remove option
                  if (hasUserVoted) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'You voted ($userVoteCount)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _handleGroupRemoveVote(context, group, viewModel),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: const TextStyle(fontSize: 12),
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
                    if (thoughtsByCategory.length > 1) const SizedBox(height: 4),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGroupTap(BuildContext context, ThoughtGroup group, RetroViewModel viewModel) async {
    final remainingVotes = viewModel.getUserRemainingVotes();
    
    if (remainingVotes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No votes remaining!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await viewModel.voteForGroup(group.id);
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

  void _handleGroupRemoveVote(BuildContext context, ThoughtGroup group, RetroViewModel viewModel) async {
    try {
      await viewModel.removeVoteFromGroup(group.id);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote removed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
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

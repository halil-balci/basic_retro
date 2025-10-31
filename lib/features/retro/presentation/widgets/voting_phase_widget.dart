import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/retro_thought.dart';
import '../retro_view_model.dart';
import '../../../../core/constants/retro_constants.dart';
import '../../../../core/presentation/widgets/common/category_column.dart';
import '../../../../core/presentation/widgets/common/votable_group_card.dart';
import '../../../../core/presentation/widgets/base_phase_widget.dart';

class VotingPhaseWidget extends BasePhaseWidget {
  const VotingPhaseWidget({super.key});

  @override
  String get phaseTitle => 'Voting Phase';

  @override
  String get phaseDescription => 'Vote for the thoughts that matter most to you';

  @override
  IconData get phaseIcon => Icons.how_to_vote;

  @override
  List<Color> get phaseGradientColors => const [Color(0xFF9333EA), Color(0xFF7C3AED)];

  @override
  String? getAdditionalInfo(BuildContext context) {
    final viewModel = Provider.of<RetroViewModel>(context, listen: false);
    return 'You have ${viewModel.getUserRemainingVotes()} votes remaining';
  }

  @override
  Widget buildPhaseContent(BuildContext context, bool isSmallScreen) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return _buildCategoriesLayout(viewModel, isSmallScreen);
      },
    );
  }

  Widget _buildCategoriesLayout(RetroViewModel viewModel, bool isSmall) {
    final categories = RetroConstants.categories.map((category) {
      final colorName = RetroConstants.categoryColors[category] ?? 'grey';
      final color = _getColorFromName(colorName);
      return MapEntry(category, color);
    }).toList();

    return isSmall
        ? Column(
            children: categories.map((entry) {
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: entry.key != categories.last.key ? 16 : 0,
                ),
                child: _buildVotingCategoryColumn(entry.key, entry.value, viewModel, isSmall),
              );
            }).toList(),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((entry) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: entry.key != categories.last.key ? 16 : 0,
                  ),
                  child: _buildVotingCategoryColumn(entry.key, entry.value, viewModel, isSmall),
                ),
              );
            }).toList(),
          );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'green':
        return const Color(0xFF10B981);
      case 'red':
        return const Color(0xFFEF4444);
      case 'blue':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildVotingCategoryColumn(String category, Color color, RetroViewModel viewModel, bool isSmallScreen) {
    return CategoryColumn(
      category: category,
      color: color,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          children: _buildVotableThoughtsList(category, viewModel),
        ),
      ),
    );
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
        child: VotableGroupCard(
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

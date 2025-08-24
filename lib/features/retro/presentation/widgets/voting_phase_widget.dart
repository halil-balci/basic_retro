import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/thought_group.dart';
import '../retro_view_model.dart';

class VotingPhaseWidget extends StatelessWidget {
  const VotingPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            Card(
              color: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.how_to_vote, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voting Phase: You have ${viewModel.getUserRemainingVotes()} votes remaining. Click on groups to vote.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildVotingGrid(viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVotingGrid(RetroViewModel viewModel) {
    final groups = viewModel.currentGroups;
    
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No groups available for voting.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createGroupsFromThoughts(viewModel),
              child: const Text('Create Groups from Thoughts'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _buildVotableGroup(group, viewModel);
      },
    );
  }

  Widget _buildVotableGroup(ThoughtGroup group, RetroViewModel viewModel) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _handleGroupTap(group, viewModel),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _getColorFromHex(group.color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${group.votes}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: group.thoughts.map((thought) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        thought.content,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${group.thoughts.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (group.hasUserVoted(viewModel.getCurrentUserId()))
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Voted (${group.getUserVoteCount(viewModel.getCurrentUserId())})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
  }

  void _handleGroupTap(ThoughtGroup group, RetroViewModel viewModel) async {
    final remainingVotes = viewModel.getUserRemainingVotes();
    
    if (remainingVotes <= 0) {
      // Show snackbar about no votes left
      return;
    }

    try {
      await viewModel.voteForGroup(group.id);
    } catch (e) {
      // Handle error - maybe show a snackbar
      debugPrint('Error voting: $e');
    }
  }

  Future<void> _createGroupsFromThoughts(RetroViewModel viewModel) async {
    try {
      // Create groups from current thoughts
      await viewModel.initializeGroupsFromThoughts();
    } catch (e) {
      debugPrint('Error creating groups from thoughts: $e');
    }
  }
}

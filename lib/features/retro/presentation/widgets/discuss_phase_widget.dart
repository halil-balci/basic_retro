import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/thought_group.dart';
import '../retro_view_model.dart';

class DiscussPhaseWidget extends StatelessWidget {
  const DiscussPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        final currentGroup = viewModel.currentDiscussionGroup;
        final sortedGroups = viewModel.sortedGroupsByVotes;
        final currentIndex = viewModel.currentSession?.currentDiscussionGroupIndex ?? 0;

        return Column(
          children: [
            const Card(
              color: Colors.teal,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.forum, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Discussion Phase: Discuss each group ordered by votes (highest to lowest).',
                        style: TextStyle(
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
            if (currentGroup != null) ...[
              _buildNavigationBar(currentIndex, sortedGroups.length, viewModel),
              const SizedBox(height: 16),
              Expanded(
                child: _buildCurrentGroupDisplay(currentGroup),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No groups available for discussion.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _createGroupsFromThoughts(viewModel),
                        child: const Text('Create Groups from Thoughts'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNavigationBar(int currentIndex, int totalGroups, RetroViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: currentIndex > 0
                  ? () => viewModel.previousDiscussionGroup()
                  : null,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Previous Group',
            ),
            Column(
              children: [
                Text(
                  'Group ${currentIndex + 1} of $totalGroups',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: totalGroups > 0 ? (currentIndex + 1) / totalGroups : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: currentIndex < totalGroups - 1
                  ? () => viewModel.nextDiscussionGroup()
                  : null,
              icon: const Icon(Icons.arrow_forward),
              tooltip: 'Next Group',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentGroupDisplay(ThoughtGroup group) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getColorFromHex(group.color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.group_work,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${group.votes} votes',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${group.thoughts.length} items',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Items in this group:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: group.thoughts.length,
                itemBuilder: (context, index) {
                  final thought = group.thoughts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(thought.category),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  thought.content,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  thought.category,
                                  style: TextStyle(
                                    color: _getCategoryColor(thought.category),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'sad':
        return Colors.green;
      case 'mad':
        return Colors.red;
      case 'glad':
        return Colors.blue;
      default:
        return Colors.grey;
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

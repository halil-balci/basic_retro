import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/thought_group.dart';
import '../../domain/retro_thought.dart';
import '../retro_view_model.dart';
import 'finish_phase_widget.dart';
import '../../../../core/constants/retro_constants.dart';

class DiscussPhaseWidget extends StatelessWidget {
  const DiscussPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        // Eğer phase finish ise bitiş ekranı göster
        if (viewModel.currentPhase.name == 'finish') {
          return const FinishPhaseWidget();
        }

        final sortedGroups = viewModel.sortedGroupsByVotes;
        final currentIndex = viewModel.currentSession?.currentDiscussionGroupIndex ?? 0;
        final currentGroup = viewModel.currentDiscussionGroup;

        // Eğer grup yoksa oluşturma seçeneği sun
        if (sortedGroups.isEmpty) {
          return Center(
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
          );
        }

        // Son grupta ise "Bitir" butonu göster
        final isLastGroup = currentIndex >= sortedGroups.length && sortedGroups.isNotEmpty;
        if (isLastGroup) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tüm gruplar tartışıldı.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: viewModel.canAdvancePhase
                      ? () async {
                          await viewModel.advancePhase();
                        }
                      : null,
                  icon: const Icon(Icons.flag),
                  label: const Text('Bitir ve Geri Bildirim Aşamasına Geç'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header card with modern design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
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
                      Icons.forum,
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
                          'Discussion Phase',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discuss each group ordered by votes (highest to lowest)',
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
            const SizedBox(height: 16),
            if (currentGroup != null) ...[
              _buildNavigationBar(currentIndex, sortedGroups.length, viewModel),
              const SizedBox(height: 16),
              Expanded(
                child: _buildCurrentGroupDisplay(currentGroup, currentIndex + 1, sortedGroups.length),
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
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: currentIndex > 0
                  ? () => viewModel.previousDiscussionGroup()
                  : null,
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Previous Group',
              style: IconButton.styleFrom(
                backgroundColor: currentIndex > 0 
                    ? const Color(0xFF6366F1)
                    : Colors.grey.shade300,
                foregroundColor: currentIndex > 0 
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: totalGroups > 0 ? (currentIndex + 1) / totalGroups : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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
              style: IconButton.styleFrom(
                backgroundColor: currentIndex < totalGroups - 1 
                    ? const Color(0xFF6366F1)
                    : Colors.grey.shade300,
                foregroundColor: currentIndex < totalGroups - 1 
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentGroupDisplay(ThoughtGroup group, int rank, int totalGroups) {
    // Group thoughts by category for better display
    final thoughtsByCategory = <String, List<RetroThought>>{};
    for (final thought in group.thoughts) {
      thoughtsByCategory.putIfAbsent(thought.category, () => []).add(thought);
    }

    return Card(
      elevation: 6,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _getPriorityColor(rank).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getPriorityColor(rank).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group header with priority and stats
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(rank),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getPriorityIcon(rank),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Priority #$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: const Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${group.votes} votes',
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_work, color: const Color(0xFF0284C7), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${group.thoughts.length} items',
                        style: const TextStyle(
                          color: Color(0xFF0C4A6E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: thoughtsByCategory.entries.map((entry) {
                  final categoryName = entry.key;
                  final categoryThoughts = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category header if more than one category
                      if (thoughtsByCategory.length > 1) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(categoryName).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getCategoryColor(categoryName).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(categoryName),
                                color: _getCategoryColor(categoryName),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                RetroConstants.categoryTitles[categoryName] ?? categoryName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(categoryName),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Show all thoughts from this category
                      ...categoryThoughts.map((thought) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getCategoryColor(categoryName).withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(categoryName),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                thought.content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (thoughtsByCategory.length > 1) const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
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

  Color _getPriorityColor(int rank) {
    if (rank <= 3) return const Color(0xFF6366F1); // Soft indigo for high priority
    if (rank <= 6) return const Color(0xFF8B5CF6); // Soft purple for medium priority
    return const Color(0xFF06B6D4); // Soft cyan for low priority
  }

  IconData _getPriorityIcon(int rank) {
    if (rank <= 3) return Icons.priority_high;
    if (rank <= 6) return Icons.trending_up;
    return Icons.info_outline;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'start':
        return const Color(0xFF10B981);
      case 'stop':
        return const Color(0xFFEF4444);
      case 'continue':
        return const Color(0xFF3B82F6);
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

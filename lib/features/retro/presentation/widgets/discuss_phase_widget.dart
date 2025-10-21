import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/thought_group.dart';
import '../../domain/entities/retro_thought.dart';
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
                  'All groups are discussed',
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
                  label: const Text('Finish and Go to Notification Phase'),
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 600;
            final isVerySmallScreen = constraints.maxWidth < 400;
            
            return Column(
              children: [
                // Header card with modern design - responsive
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 20)),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSmallScreen 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(isVerySmallScreen ? 4 : 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.forum,
                                  color: Colors.white,
                                  size: isVerySmallScreen ? 16 : 20,
                                ),
                              ),
                              SizedBox(width: isVerySmallScreen ? 8 : 12),
                              Expanded(
                                child: Text(
                                  'Discussion Phase',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isVerySmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isVerySmallScreen ? 6 : 8),
                          Text(
                            'Discuss each group ordered by votes (highest to lowest)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isVerySmallScreen ? 11 : 13,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      )
                    : Row(
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
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                ),
                SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                if (currentGroup != null) ...[
                  _buildNavigationBar(currentIndex, sortedGroups.length, viewModel, isSmallScreen, isVerySmallScreen),
                  SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                  Expanded(
                    child: _buildCurrentGroupDisplay(
                      currentGroup, 
                      currentIndex + 1, 
                      sortedGroups.length, 
                      isSmallScreen,
                      isVerySmallScreen,
                    ),
                  ),
                ] else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No groups available for discussion.',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16), 
                              color: Colors.grey
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                          ElevatedButton(
                            onPressed: () => _createGroupsFromThoughts(viewModel),
                            child: Text(
                              'Create Groups from Thoughts',
                              style: TextStyle(fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 13 : 14)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNavigationBar(int currentIndex, int totalGroups, RetroViewModel viewModel, bool isSmallScreen, bool isVerySmallScreen) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 16.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isSmallScreen 
          ? Column(
              children: [
                Text(
                  'Group ${currentIndex + 1} of $totalGroups',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isVerySmallScreen ? 8 : 12),
                SizedBox(
                  width: double.infinity,
                  height: isVerySmallScreen ? 4 : 6,
                  child: LinearProgressIndicator(
                    value: totalGroups > 0 ? (currentIndex + 1) / totalGroups : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
                SizedBox(height: isVerySmallScreen ? 8 : 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: isVerySmallScreen ? 36 : 40,
                        child: ElevatedButton.icon(
                          onPressed: currentIndex > 0
                              ? () => viewModel.previousDiscussionGroup()
                              : null,
                          icon: Icon(Icons.arrow_back, size: isVerySmallScreen ? 16 : 18),
                          label: isVerySmallScreen 
                              ? const SizedBox.shrink()
                              : const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentIndex > 0 
                                ? const Color(0xFF6366F1)
                                : Colors.grey.shade300,
                            foregroundColor: currentIndex > 0 
                                ? Colors.white
                                : Colors.grey.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isVerySmallScreen ? 8 : 16),
                    Expanded(
                      child: Container(
                        height: isVerySmallScreen ? 36 : 40,
                        child: ElevatedButton.icon(
                          onPressed: currentIndex < totalGroups - 1
                              ? () => viewModel.nextDiscussionGroup()
                              : null,
                          icon: Icon(Icons.arrow_forward, size: isVerySmallScreen ? 16 : 18),
                          label: isVerySmallScreen 
                              ? const SizedBox.shrink()
                              : const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentIndex < totalGroups - 1 
                                ? const Color(0xFF6366F1)
                                : Colors.grey.shade300,
                            foregroundColor: currentIndex < totalGroups - 1 
                                ? Colors.white
                                : Colors.grey.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Row(
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

  Widget _buildCurrentGroupDisplay(ThoughtGroup group, int rank, int totalGroups, bool isSmallScreen, bool isVerySmallScreen) {
    // Group thoughts by category for better display
    final thoughtsByCategory = <String, List<RetroThought>>{};
    for (final thought in group.thoughts) {
      thoughtsByCategory.putIfAbsent(thought.category, () => []).add(thought);
    }

    return Card(
      elevation: 6,
      child: Container(
        padding: EdgeInsets.all(isVerySmallScreen ? 12.0 : (isSmallScreen ? 16.0 : 24.0)),
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
            // Group header with priority and stats - responsive
            isSmallScreen 
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isVerySmallScreen ? 8 : 12, 
                        vertical: isVerySmallScreen ? 4 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(rank),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPriorityIcon(rank),
                            color: Colors.white,
                            size: isVerySmallScreen ? 12 : 16,
                          ),
                          SizedBox(width: isVerySmallScreen ? 4 : 6),
                          Flexible(
                            child: Text(
                              'Priority #$rank',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isVerySmallScreen ? 10 : 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isVerySmallScreen ? 6 : 8),
                    Wrap(
                      spacing: isVerySmallScreen ? 6 : 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 6 : 8, 
                            vertical: isVerySmallScreen ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, color: const Color(0xFFEF4444), size: isVerySmallScreen ? 10 : 12),
                              SizedBox(width: isVerySmallScreen ? 1 : 2),
                              Text(
                                '${group.votes}',
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: isVerySmallScreen ? 9 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 6 : 8, 
                            vertical: isVerySmallScreen ? 2 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_work, color: const Color(0xFF0284C7), size: isVerySmallScreen ? 10 : 12),
                              SizedBox(width: isVerySmallScreen ? 1 : 2),
                              Text(
                                '${group.thoughts.length}',
                                style: TextStyle(
                                  color: Color(0xFF0C4A6E),
                                  fontSize: isVerySmallScreen ? 9 : 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
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
                    Wrap(
                      spacing: 12,
                      children: [
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
                  ],
                ),
            SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 16 : 24)),
            Text(
              'Items in this group:',
              style: TextStyle(
                fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
            Expanded(
              child: ListView.builder(
                itemCount: thoughtsByCategory.entries.length,
                itemBuilder: (context, categoryIndex) {
                  final entry = thoughtsByCategory.entries.elementAt(categoryIndex);
                  final categoryName = entry.key;
                  final categoryThoughts = entry.value;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category header if more than one category
                      if (thoughtsByCategory.length > 1) ...[
                        Container(
                          margin: EdgeInsets.only(
                            bottom: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12), 
                            vertical: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8),
                          ),
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
                                size: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                              ),
                              SizedBox(width: isVerySmallScreen ? 4 : (isSmallScreen ? 6 : 8)),
                              Flexible(
                                child: Text(
                                  RetroConstants.categoryTitles[categoryName] ?? categoryName,
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                                    fontWeight: FontWeight.bold,
                                    color: _getCategoryColor(categoryName),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Show all thoughts from this category
                      ...categoryThoughts.asMap().entries.map((thoughtEntry) {
                        final thought = thoughtEntry.value;
                        
                        return Container(
                          margin: EdgeInsets.only(
                            bottom: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12),
                          ),
                          padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
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
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  width: isVerySmallScreen ? 2 : (isSmallScreen ? 3 : 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(categoryName),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                SizedBox(width: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 12)),
                                Expanded(
                                  child: SelectableText(
                                    thought.content,
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 16),
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF374151),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (thoughtsByCategory.length > 1 && categoryIndex < thoughtsByCategory.length - 1) 
                        SizedBox(height: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Mad':
        return Icons.not_interested;
      case 'Sad':
        return Icons.thumb_down_rounded;
      case 'Glad':
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../retro_view_model.dart';
import 'finish_phase_widget.dart';
import 'action_items_panel.dart';
import '../../../../core/presentation/widgets/base_phase_widget.dart';
import '../../../../core/presentation/widgets/common/discussion_navigation_bar.dart';
import '../../../../core/presentation/widgets/common/group_display_card.dart';

class DiscussPhaseWidget extends BasePhaseWidget {
  const DiscussPhaseWidget({super.key});

  @override
  String get phaseTitle => 'Discussion Phase';

  @override
  String get phaseDescription => 'Discuss each group ordered by votes (highest to lowest)';

  @override
  IconData get phaseIcon => Icons.forum;

  @override
  List<Color> get phaseGradientColors => const [Color(0xFF059669), Color(0xFF047857)];

  @override
  Widget buildPhaseContent(BuildContext context, bool isSmallScreen) {
    return Consumer<RetroViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.currentPhase.name == 'finish') {
          return const FinishPhaseWidget();
        }

        final sortedGroups = viewModel.sortedGroupsByVotes;
        final currentIndex = viewModel.currentSession?.currentDiscussionGroupIndex ?? 0;
        final currentGroup = viewModel.currentDiscussionGroup;

        if (sortedGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No groups available for discussion.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey,
                  ),
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

        final isLastGroup = currentIndex >= sortedGroups.length && sortedGroups.isNotEmpty;
        if (isLastGroup) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'All groups are discussed',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
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

        if (currentGroup == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No groups available for discussion.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DiscussionNavigationBar(
              currentIndex: currentIndex,
              totalGroups: sortedGroups.length,
              onPrevious: () => viewModel.previousDiscussionGroup(),
              onNext: () => viewModel.nextDiscussionGroup(),
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
            isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GroupDisplayCard(
                        group: currentGroup,
                        rank: currentIndex + 1,
                        totalGroups: sortedGroups.length,
                        isSmallScreen: isSmallScreen,
                      ),
                      const SizedBox(height: 16),
                      const ActionItemsPanel(
                        isSmallScreen: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: GroupDisplayCard(
                          group: currentGroup,
                          rank: currentIndex + 1,
                          totalGroups: sortedGroups.length,
                          isSmallScreen: false,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const SizedBox(
                        width: 400,
                        child: ActionItemsPanel(
                          isSmallScreen: false,
                        ),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }

  Future<void> _createGroupsFromThoughts(RetroViewModel viewModel) async {
    try {
      await viewModel.initializeGroupsFromThoughts();
    } catch (e) {
      debugPrint('Error creating groups from thoughts: $e');
    }
  }
}

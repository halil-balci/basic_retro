import 'package:flutter/material.dart';

/// Common widget for discussion phase navigation
/// Allows navigating between discussion groups with progress indicator
class DiscussionNavigationBar extends StatelessWidget {
  final int currentIndex;
  final int totalGroups;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool isSmallScreen;

  const DiscussionNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalGroups,
    this.onPrevious,
    this.onNext,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final isVerySmallScreen = MediaQuery.of(context).size.width < 400;
    
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
          ? _buildSmallScreenLayout(isVerySmallScreen)
          : _buildLargeScreenLayout(),
      ),
    );
  }

  Widget _buildSmallScreenLayout(bool isVerySmallScreen) {
    return Column(
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
              child: SizedBox(
                height: isVerySmallScreen ? 36 : 40,
                child: ElevatedButton.icon(
                  onPressed: currentIndex > 0 ? onPrevious : null,
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
              child: SizedBox(
                height: isVerySmallScreen ? 36 : 40,
                child: ElevatedButton.icon(
                  onPressed: currentIndex < totalGroups - 1 ? onNext : null,
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
    );
  }

  Widget _buildLargeScreenLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: currentIndex > 0 ? onPrevious : null,
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
          onPressed: currentIndex < totalGroups - 1 ? onNext : null,
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
    );
  }
}

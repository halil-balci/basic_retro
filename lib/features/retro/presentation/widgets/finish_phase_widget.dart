import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/feedback_service.dart';
import '../../../../services/action_item_export_service.dart';
import '../retro_view_model.dart';

class FinishPhaseWidget extends StatefulWidget {
  const FinishPhaseWidget({super.key});

  @override
  State<FinishPhaseWidget> createState() => _FinishPhaseWidgetState();
}


class _FinishPhaseWidgetState extends State<FinishPhaseWidget> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(_onFeedbackChanged);
  }

  @override
  void dispose() {
    _feedbackController.removeListener(_onFeedbackChanged);
    _feedbackController.dispose();
    super.dispose();
  }

  void _onFeedbackChanged() {
    setState(() {});
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) return;
    try {
      await FeedbackService.sendFeedback(feedback);
      setState(() {
        _submitted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your feedback could not be sent: $e')),
      );
    }
  }

  Widget _buildLargeScreenLayout(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Consumer<RetroViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  // Top Row - Celebration and Thank You cards
                  Expanded(
                    child: Row(
                      children: [
                        // Celebration card
                        Expanded(
                          child: _buildCelebrationCard(),
                        ),
                        const SizedBox(width: 16),
                        // Thank You card
                        Expanded(
                          child: _buildThankYouCard(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bottom Row - Action Items and Feedback cards
                  Expanded(
                    child: Row(
                      children: [
                        // Action Items card
                        Expanded(
                          child: viewModel.cachedActionItems.isNotEmpty
                              ? _buildActionItemsSummary(viewModel)
                              : _buildEmptyActionItemsCard(),
                        ),
                        const SizedBox(width: 16),
                        // Feedback card
                        Expanded(
                          child: _buildFeedbackCard(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.celebration,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Congratulations!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You have successfully completed all phases.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            color: Color(0xFF6366F1),
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Thank you for your participation!',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'See you at the next retrospective!',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActionItemsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              color: Color(0xFF6366F1),
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Action Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No action items were created in this retrospective.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
                  height: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: !_submitted
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.feedback_outlined,
                                  color: Color(0xFF6366F1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Share Your Feedback',
                                  style: TextStyle(
                                    color: Color(0xFF1E293B),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'You can share your thoughts, wishes, and requests regarding the project with us:',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: TextField(
                              controller: _feedbackController,
                              minLines: null,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                ),
                                hintText: 'Write your thoughts, wishes, or requests...\n\nYou can write as much as you want here.',
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                contentPadding: const EdgeInsets.all(16),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _feedbackController.text.trim().isEmpty ? null : _submitFeedback,
                              icon: const Icon(
                                Icons.send,
                                size: 18,
                              ),
                              label: const Text(
                                'Send Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Thank you for your feedback!',
                              style: TextStyle(
                                fontSize: 24,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Your input helps us improve the experience for everyone.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        final isVerySmallScreen = constraints.maxWidth < 400;
        final isMediumScreen = constraints.maxWidth < 900;
        final isLargeScreen = constraints.maxWidth >= 900;
        final screenHeight = constraints.maxHeight;
        
        // For large screens, use a 2x2 grid layout
        if (isLargeScreen && screenHeight > 600) {
          return _buildLargeScreenLayout(constraints);
        }
        
        // For smaller screens, use scrollable vertical layout with all 4 cards
        return Consumer<RetroViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isVerySmallScreen ? 16.0 : (isSmallScreen ? 24.0 : 32.0)),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isMediumScreen ? double.infinity : 800,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Celebration header card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 32)),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.celebration,
                                color: Colors.white,
                                size: isVerySmallScreen ? 48 : (isSmallScreen ? 64 : 80),
                              ),
                            ),
                            SizedBox(height: isVerySmallScreen ? 16 : 24),
                            Text(
                              'Congratulations!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isVerySmallScreen ? 20 : (isSmallScreen ? 24 : 28),
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isVerySmallScreen ? 8 : 12),
                            Text(
                              'You have successfully completed all phases.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                      
                      // 2. Thank you message card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6366F1).withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: const Color(0xFF6366F1),
                              size: isVerySmallScreen ? 32 : (isSmallScreen ? 40 : 48),
                            ),
                            SizedBox(height: isVerySmallScreen ? 12 : 16),
                            Text(
                              'Thank you for your participation!',
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isVerySmallScreen ? 8 : 12),
                            Text(
                              'See you at the next retrospective!',
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 15 : 16),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                      
                      // 3. Action Items Summary (if available)
                      if (viewModel.cachedActionItems.isNotEmpty) ...[
                        _buildActionItemsSummarySmallScreen(viewModel, isVerySmallScreen, isSmallScreen),
                        SizedBox(height: isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                      ],
                      
                      // 4. Feedback section
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: !_submitted 
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6366F1).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.feedback_outlined,
                                        color: const Color(0xFF6366F1),
                                        size: isVerySmallScreen ? 16 : 20,
                                      ),
                                    ),
                                    SizedBox(width: isVerySmallScreen ? 8 : 12),
                                    Expanded(
                                      child: Text(
                                        'Share Your Feedback',
                                        style: TextStyle(
                                          color: const Color(0xFF1E293B),
                                          fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isVerySmallScreen ? 8 : 12),
                                Text(
                                  'You can share your thoughts, wishes, and requests regarding the project with us:',
                                  style: TextStyle(
                                    color: const Color(0xFF64748B),
                                    fontSize: isVerySmallScreen ? 12 : (isSmallScreen ? 14 : 15),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: isVerySmallScreen ? 16 : 20),
                                TextField(
                                  controller: _feedbackController,
                                  minLines: isVerySmallScreen ? 2 : 3,
                                  maxLines: isVerySmallScreen ? 4 : 6,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                                    ),
                                    hintText: 'Write your thoughts, wishes, or requests...',
                                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                    contentPadding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 14 : 15,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: isVerySmallScreen ? 16 : 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: isVerySmallScreen ? 44 : 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _feedbackController.text.trim().isEmpty ? null : _submitFeedback,
                                    icon: Icon(
                                      Icons.send,
                                      size: isVerySmallScreen ? 16 : 18,
                                    ),
                                    label: Text(
                                      'Send Feedback',
                                      style: TextStyle(
                                        fontSize: isVerySmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6366F1),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isVerySmallScreen ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF10B981),
                                    size: isVerySmallScreen ? 32 : 40,
                                  ),
                                ),
                                SizedBox(height: isVerySmallScreen ? 12 : 16),
                                Text(
                                  'Thank you for your feedback!',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                                    color: const Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isVerySmallScreen ? 6 : 8),
                                Text(
                                  'Your input helps us improve the experience for everyone.',
                                  style: TextStyle(
                                    fontSize: isVerySmallScreen ? 12 : 14,
                                    color: const Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionItemsSummarySmallScreen(RetroViewModel viewModel, bool isVerySmallScreen, bool isSmallScreen) {
    final totalCount = viewModel.cachedActionItems.length;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isVerySmallScreen ? 16 : (isSmallScreen ? 20 : 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isVerySmallScreen ? 6 : 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.checklist_rounded,
                  color: const Color(0xFF6366F1),
                  size: isVerySmallScreen ? 20 : 24,
                ),
              ),
              SizedBox(width: isVerySmallScreen ? 8 : 12),
              Expanded(
                child: Text(
                  'Action Items Summary',
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isVerySmallScreen ? 12 : 16),
          // Stats
          Center(
            child: _buildStatCard(
              'Total Action Items',
              totalCount.toString(),
              const Color(0xFF6366F1),
            ),
          ),
          SizedBox(height: isVerySmallScreen ? 12 : 16),
          // Export button (text only)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportActionItems(viewModel),
              icon: Icon(Icons.description_outlined, size: isVerySmallScreen ? 16 : 18),
              label: Text(
                'Export as Text',
                style: TextStyle(fontSize: isVerySmallScreen ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isVerySmallScreen ? 10 : 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItemsSummary(RetroViewModel viewModel) {
    final totalCount = viewModel.cachedActionItems.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Action Items Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stats
          Expanded(
            child: Center(
              child: _buildStatCard(
                'Total Action Items',
                totalCount.toString(),
                const Color(0xFF6366F1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Export button (text only)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportActionItems(viewModel),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Export as Text'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _exportActionItems(RetroViewModel viewModel) {
    if (viewModel.currentSession == null) return;

    try {
      ActionItemExportService.exportToText(
        actionItems: viewModel.cachedActionItems,
        groups: viewModel.currentGroups,
        session: viewModel.currentSession!,
      );
    } catch (e) {
      debugPrint('Error exporting action items: $e');
    }
  }
}

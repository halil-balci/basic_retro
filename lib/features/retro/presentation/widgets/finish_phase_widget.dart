import 'package:flutter/material.dart';
import '../../../../services/feedback_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text(
              'Congratulations! You have successfully completed all phases.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Thank you for your participation.\nSee you at the next retrospective!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_submitted) ...[
              Text(
                'You can share your thoughts, wishes, and requests regarding the project with us:',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _feedbackController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write your thoughts, wishes, or requests...',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _feedbackController.text.trim().isEmpty ? null : _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.blue, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Thank you for your feedback!',
                style: TextStyle(fontSize: 16, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
        SnackBar(content: Text('Görüşünüz gönderilemedi: $e')),
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
              'Tebrikler! Tüm aşamaları başarıyla tamamladınız.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Katılımınız için teşekkür ederiz.\nBir sonraki retrospektifte görüşmek üzere!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (!_submitted) ...[
              Text(
                'Proje ile ilgili görüş, dilek ve isteklerinizi bizimle paylaşabilirsiniz:',
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
                  hintText: 'Görüş, dilek veya isteklerinizi yazınız...',
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _feedbackController.text.trim().isEmpty ? null : _submitFeedback,
                icon: const Icon(Icons.send),
                label: const Text('Gönder'),
              ),
            ] else ...[
              const Icon(Icons.check_circle, color: Colors.blue, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Görüşünüz için teşekkürler!',
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

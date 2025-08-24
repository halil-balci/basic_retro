import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  static final _collection = FirebaseFirestore.instance.collection('user_feedbacks');

  static Future<void> sendFeedback(String feedback, {String? userId}) async {
    await _collection.add({
      'feedback': feedback,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

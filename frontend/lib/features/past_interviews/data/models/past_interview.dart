import '../../../../features/interview/data/models/evaluation_models.dart';

class PastInterview {
  final int id;
  final String company;
  final String role;
  final String status;
  final DateTime createdAt;
  final FinalEvaluation? feedbackJson;
  final List<dynamic>? transcriptJson;

  PastInterview({
    required this.id,
    required this.company,
    required this.role,
    required this.status,
    required this.createdAt,
    this.feedbackJson,
    this.transcriptJson,
  });

  factory PastInterview.fromJson(Map<String, dynamic> json) {
    FinalEvaluation? parsedFeedback;
    if (json['feedback_json'] != null) {
      try {
        parsedFeedback = FinalEvaluation.fromJson(json['feedback_json']);
      } catch (e) {
        // If feedback parsing fails, keep it null so the interview still shows up in the list
        // as either processing or just incomplete, rather than completely breaking the list.
      }
    }

    return PastInterview(
      id: json['id'] as int,
      company: json['company'] as String? ?? 'Unknown',
      role: json['role'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
      feedbackJson: parsedFeedback,
      transcriptJson: json['transcript_json'] as List<dynamic>?,
    );
  }
}

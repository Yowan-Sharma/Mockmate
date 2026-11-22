import 'package:mockmate/features/interview/data/models/evaluation_models.dart';

enum InterviewStatus {
  setup,
  initializing,
  ready,
  inProgress,
  processing,
  completed,
  error
}

class ChatMessage {
  final String role; // 'user' or 'ai'
  final String content;
  final bool isAudio;

  ChatMessage({
    required this.role,
    required this.content,
    this.isAudio = false,
  });
}

class InterviewState {
  final InterviewStatus status;
  final String? company;
  final String? topic;
  final String? role;
  final String? interviewType;
  final String? interviewMode;
  final int? topicId;
  final List<ChatMessage> messages;
  final bool isInterviewerSpeaking;
  final bool isListening;
  final String? errorMessage;
  final FinalEvaluation? evaluation;
  final bool isCameraOn;
  final bool isMicOn;
  final int? duration;
  final String? difficulty;
  final String? jdText;
  final String? resumeText;
  final String? pendingTranscript;
  final int? interviewId;

  InterviewState({
    this.status = InterviewStatus.setup,
    this.company,
    this.topic,
    this.role,
    this.interviewType,
    this.interviewMode,
    this.topicId,
    this.messages = const [],
    this.isInterviewerSpeaking = false,
    this.isListening = false,
    this.errorMessage,
    this.evaluation,
    this.isCameraOn = true,
    this.isMicOn = true,
    this.duration,
    this.difficulty,
    this.jdText,
    this.resumeText,
    this.pendingTranscript,
    this.interviewId,
  });

  InterviewState copyWith({
    InterviewStatus? status,
    String? company,
    String? topic,
    String? role,
    String? interviewType,
    String? interviewMode,
    int? topicId,
    List<ChatMessage>? messages,
    bool? isInterviewerSpeaking,
    bool? isListening,
    String? errorMessage,
    FinalEvaluation? evaluation,
    bool? isCameraOn,
    bool? isMicOn,
    int? duration,
    String? difficulty,
    String? jdText,
    String? resumeText,
    String? pendingTranscript,
    int? interviewId,
  }) {
    return InterviewState(
      status: status ?? this.status,
      company: company ?? this.company,
      topic: topic ?? this.topic,
      role: role ?? this.role,
      interviewType: interviewType ?? this.interviewType,
      interviewMode: interviewMode ?? this.interviewMode,
      topicId: topicId ?? this.topicId,
      messages: messages ?? this.messages,
      isInterviewerSpeaking: isInterviewerSpeaking ?? this.isInterviewerSpeaking,
      isListening: isListening ?? this.isListening,
      errorMessage: errorMessage ?? this.errorMessage,
      evaluation: evaluation ?? this.evaluation,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isMicOn: isMicOn ?? this.isMicOn,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      jdText: jdText ?? this.jdText,
      resumeText: resumeText ?? this.resumeText,
      pendingTranscript: pendingTranscript ?? this.pendingTranscript,
      interviewId: interviewId ?? this.interviewId,
    );
  }
}

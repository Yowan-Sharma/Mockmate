import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../services/api_service.dart';
import '../../data/models/interview_session.dart';
import '../../data/models/evaluation_models.dart';

class InterviewNotifier extends StateNotifier<InterviewState> {
  InterviewNotifier() : super(InterviewState()) {
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlayingAudio = false;
      if (_audioQueue.isNotEmpty) {
        _playNextAudio();
      } else {
        _checkAndTransitionToListening();
      }
    });
  }

  WebSocketChannel? _chatChannel;
  WebSocketChannel? _transcribeChannel;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  final String _clientId = const Uuid().v4();
  String? _pendingTranscript;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Uint8List> _audioQueue = [];
  bool _isPlayingAudio = false;
  bool _isStreamEnded = false;
  Timer? _silenceTimer;
  Timer? _pollingTimer;
  bool _isPolling = false;

  void _enqueueAudio(Uint8List audioBytes) {
    _audioQueue.add(audioBytes);
    _playNextAudio();
  }

  Future<void> _playNextAudio() async {
    if (_isPlayingAudio || _audioQueue.isEmpty) return;
    _isPlayingAudio = true;
    final nextChunk = _audioQueue.removeAt(0);
    
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/tts_chunk_${DateTime.now().millisecondsSinceEpoch}.mp3');
      await file.writeAsBytes(nextChunk);
      await _audioPlayer.play(DeviceFileSource(file.path));
    } catch (e) {
      debugPrint('Error playing audio chunk: $e');
      _isPlayingAudio = false;
      if (_audioQueue.isNotEmpty) {
        _playNextAudio();
      } else {
        _checkAndTransitionToListening();
      }
    }
  }

  void _checkAndTransitionToListening() {
    if (_isStreamEnded && _audioQueue.isEmpty && !_isPlayingAudio) {
      state = state.copyWith(isInterviewerSpeaking: false, isListening: true);
    }
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 3), () async {
      final isRecording = await _audioRecorder.isRecording();
      if (isRecording) {
        state = state.copyWith(isMicOn: false);
        await stopRecordingAndSend();
      }
    });
  }

  String get _wsBaseUrl {
    final httpUrl = ApiService.baseUrl;
    if (httpUrl.startsWith('https')) {
      return httpUrl.replaceFirst('https', 'wss');
    }
    return httpUrl.replaceFirst('http', 'ws');
  }

  void initializeSetup({
    String? company,
    String? topic,
    String? role,
    String? interviewType,
    String? interviewMode,
    int? topicId,
  }) {
    // Clean up any existing WebSocket connection from a previous interview
    _chatChannel?.sink.close();
    _chatChannel = null;
    _transcribeChannel?.sink.close();
    _transcribeChannel = null;
    _audioStreamSubscription?.cancel();
    _audioQueue.clear();
    _audioPlayer.stop();
    _pollingTimer?.cancel();
    _isPolling = false;
    _pendingTranscript = null;
    _isPlayingAudio = false;
    _isStreamEnded = false;

    state = InterviewState(
      status: InterviewStatus.setup,
      company: company,
      topic: topic,
      role: role,
      interviewType: interviewType,
      interviewMode: interviewMode,
      topicId: topicId,
      messages: [],
    );
  }

  void saveSetupData({int? duration, String? difficulty, String? jdText, String? resumeText}) {
    state = state.copyWith(
      duration: duration,
      difficulty: difficulty,
      jdText: jdText,
      resumeText: resumeText,
    );
  }

  void loadHistoricalInterview(String company, String role, FinalEvaluation evaluation, {List<dynamic>? transcriptJson}) {
    List<ChatMessage> messages = [];
    if (transcriptJson != null) {
      messages = transcriptJson.map((msg) => ChatMessage(
        role: msg['role'] == 'user' ? 'user' : 'ai',
        content: msg['content']?.toString() ?? '',
      )).toList();
    }

    state = InterviewState(
      status: InterviewStatus.completed,
      company: company,
      role: role,
      evaluation: evaluation,
      messages: messages,
    );
  }

  Future<void> startInterview() async {
    state = state.copyWith(status: InterviewStatus.initializing);
    try {
      final token = await SecureStorage.getToken();
      final wsUrl = '$_wsBaseUrl/interview/chat/$_clientId?token=${token ?? ''}';
      _chatChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _chatChannel!.stream.listen(
        _onChatMessage,
        onError: _onChatError,
        onDone: _onChatDone,
      );

      final initPayload = {
        'type': 'init',
        'interview_type': state.interviewType ?? 'technical',
        'interview_mode': state.interviewMode ?? 'general',
        'company': state.company ?? '',
        'role': state.role ?? '',
        'topic_id': state.topicId?.toString() ?? '',
        'topic_name': state.topic ?? '',
        'duration': state.duration ?? 0,
        'difficulty': state.difficulty ?? 'Medium',
        'jd_text': state.jdText ?? '',
        'resume_text': state.resumeText ?? '',
      };

      _chatChannel!.sink.add(jsonEncode(initPayload));
      // State remains initializing until we get stream_start or text
    } catch (e) {
      state = state.copyWith(status: InterviewStatus.error, errorMessage: e.toString());
    }
  }

  void _onChatMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      final type = data['type'];

      if (data['interview_id'] != null) {
        final id = (data['interview_id'] as num).toInt();
        if (state.interviewId != id) {
          state = state.copyWith(interviewId: id);
        }
      }

      if (type == 'info' || type == 'stream_start' || type == 'metadata' || type == 'audio' || type == 'stream_end' || type == 'restored') {
        // We're good, transition to ready or inProgress
        if (state.status == InterviewStatus.initializing) {
          state = state.copyWith(status: InterviewStatus.ready);
        }
      }

      if (type == 'restored') {
        final restoredMessages = (data['messages'] as List?)?.map((msg) => ChatMessage(
          role: (msg['role'] == 'user' || msg['role'] == 'candidate') ? 'user' : 'ai',
          content: msg['content']?.toString() ?? '',
        )).toList() ?? [];
        
        state = state.copyWith(
          messages: restoredMessages,
          interviewType: data['interview_type'] ?? state.interviewType,
          role: data['role'] ?? state.role,
          company: data['company'] ?? state.company,
        );
      } else if (type == 'stream_start') {
        _isStreamEnded = false;
        _audioQueue.clear();
        _audioPlayer.stop();
        _isPlayingAudio = false;
        
        state = state.copyWith(isInterviewerSpeaking: true, isListening: false);
        // Add empty AI message to append to
        state = state.copyWith(
          messages: [...state.messages, ChatMessage(role: 'ai', content: '')],
        );
      } else if (type == 'text') {
        final content = data['content'] as String;
        if (state.messages.isNotEmpty && state.messages.last.role == 'ai') {
          final lastMsg = state.messages.last;
          final updatedMsg = ChatMessage(
            role: 'ai',
            content: lastMsg.content + content,
            isAudio: lastMsg.isAudio,
          );
          final updatedMessages = List<ChatMessage>.from(state.messages);
          updatedMessages.removeLast();
          updatedMessages.add(updatedMsg);
          state = state.copyWith(messages: updatedMessages);
        }
      } else if (type == 'audio') {
        final base64String = data['base64'] as String;
        final audioBytes = base64Decode(base64String);
        _enqueueAudio(audioBytes);
      } else if (type == 'stream_end') {
        _isStreamEnded = true;
        _checkAndTransitionToListening();
      } else if (type == 'end_interview') {
        final int? id = data['interview_id'] != null
            ? (data['interview_id'] as num).toInt()
            : state.interviewId;
        if (id != null && state.interviewId != id) {
          state = state.copyWith(interviewId: id);
        }

        if (data['feedback'] != null) {
          _pollingTimer?.cancel();
          _isPolling = false;
          final evaluation = FinalEvaluation.fromJson(data['feedback']);
          state = state.copyWith(
            status: InterviewStatus.completed,
            evaluation: evaluation,
          );
        } else if (data['status'] == 'processing_feedback') {
          state = state.copyWith(status: InterviewStatus.processing);
          pollEvaluation(id ?? state.interviewId);
        } else if (data['error'] != null) {
          state = state.copyWith(
            status: InterviewStatus.error,
            errorMessage: data['error'],
          );
        }
      } else if (type == 'error') {
        state = state.copyWith(
          status: InterviewStatus.error,
          errorMessage: data['content'],
        );
      }
    } catch (e) {
      debugPrint('Error parsing chat message: $e');
      if (state.status == InterviewStatus.processing) {
        state = state.copyWith(
          status: InterviewStatus.error,
          errorMessage: 'Failed to parse evaluation data: $e',
        );
      }
    }
  }

  void _onChatError(Object error) {
    debugPrint('Chat WebSocket Error: $error');
    if (state.status == InterviewStatus.processing) {
      debugPrint('[POLL] WebSocket error during processing, falling back to polling...');
      pollEvaluation(state.interviewId);
    } else if (state.status != InterviewStatus.completed) {
      state = state.copyWith(status: InterviewStatus.error, errorMessage: error.toString());
    }
  }

  void _onChatDone() {
    debugPrint('Chat WebSocket Closed. Current status: ${state.status}');
    if (state.status == InterviewStatus.processing) {
      debugPrint('[POLL] WebSocket closed during processing, starting/continuing polling...');
      pollEvaluation(state.interviewId);
    }
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    // Add user message to UI
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: 'user', content: text)],
      isListening: false,
    );

    _chatChannel?.sink.add(jsonEncode({
      'type': 'message',
      'content': text,
    }));
  }

  Future<bool> startRecording() async {
    try {
      debugPrint('[MIC] startRecording called. isMicOn: ${state.isMicOn}');
      if (!state.isMicOn) return false;
      
      final hasPerm = await _audioRecorder.hasPermission();
      debugPrint('[MIC] hasPermission: $hasPerm');
      
      if (!hasPerm) return false;
      
      final token = await SecureStorage.getToken();
      final wsUrl = '$_wsBaseUrl/interview/transcribe/$_clientId?token=${token ?? ''}';
      debugPrint('[MIC] Connecting to WebSocket: $wsUrl');
      
      _transcribeChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _transcribeChannel!.stream.listen(
        (message) {
           debugPrint('[MIC] Received WS message: $message');
           if (message is String) {
             final data = jsonDecode(message);
             if (data['type'] == 'partial' || data['type'] == 'final') {
               _pendingTranscript = data['text'];
               state = state.copyWith(pendingTranscript: _pendingTranscript);
               
               if (_pendingTranscript != null && _pendingTranscript!.trim().isNotEmpty) {
                 _resetSilenceTimer();
               }
             }
           }
        },
        onError: (e) => debugPrint('[MIC] Transcribe WebSocket Error: $e'),
        onDone: () => debugPrint('[MIC] Transcribe WebSocket Closed'),
      );

      debugPrint('[MIC] Starting audio stream...');
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      int chunkCount = 0;
      _audioStreamSubscription = stream.listen((data) {
        chunkCount++;
        if (chunkCount % 50 == 0) debugPrint('[MIC] Sent 50 chunks...');
        _transcribeChannel?.sink.add(data);
      }, onError: (e) => debugPrint('[MIC] Audio stream error: $e'));
      
      return true;
    } catch (e) {
      debugPrint('[MIC] Error starting recording: $e');
      return false;
    }
  }

  Future<void> stopRecordingAndSend() async {
    _silenceTimer?.cancel();
    try {
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();
      _transcribeChannel?.sink.add(jsonEncode({'type': 'end'}));
      await Future.delayed(const Duration(milliseconds: 500)); // wait for final text
      _transcribeChannel?.sink.close();
      
      if (_pendingTranscript != null && _pendingTranscript!.trim().isNotEmpty) {
        await sendTextMessage(_pendingTranscript!);
      }
      _pendingTranscript = null;
      state = state.copyWith(pendingTranscript: '');
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  void toggleCamera() {
    state = state.copyWith(isCameraOn: !state.isCameraOn);
  }

  Future<void> toggleMic() async {
    state = state.copyWith(isMicOn: !state.isMicOn);
    if (!state.isMicOn) {
      // If mic turned off while listening, stop recording
      final isRecording = await _audioRecorder.isRecording();
      if (state.isListening && isRecording) {
        await stopRecordingAndSend();
      }
    }
  }

  Future<void> endInterview() async {
    state = state.copyWith(status: InterviewStatus.processing);
    try {
      debugPrint('[WS] Sending end_session to backend...');
      _chatChannel?.sink.add(jsonEncode({'type': 'end_session'}));
      
      _isStreamEnded = true;
      _audioQueue.clear();
      _audioPlayer.stop();
      _isPlayingAudio = false;
      
      await _audioStreamSubscription?.cancel();
      await _audioRecorder.stop();

      // If feedback does not arrive via WebSocket within 4 seconds, kick off polling as fallback
      Future.delayed(const Duration(seconds: 4), () {
        if (state.status == InterviewStatus.processing && !_isPolling) {
          pollEvaluation(state.interviewId);
        }
      });
    } catch (e) {
      debugPrint('Error ending interview: $e');
      if (state.status == InterviewStatus.processing) {
        pollEvaluation(state.interviewId);
      }
    }
  }

  Future<void> pollEvaluation([int? targetInterviewId]) async {
    if (_isPolling) return;
    _isPolling = true;

    final token = await SecureStorage.getToken();
    if (token == null) {
      debugPrint('[POLL] No auth token found. Cannot poll interview evaluation.');
      _isPolling = false;
      return;
    }

    int? interviewId = targetInterviewId ?? state.interviewId;

    // If interviewId is unknown, try to find the latest interview
    if (interviewId == null) {
      try {
        final list = await ApiService.getInterviews(token);
        if (list.isNotEmpty && list.first['id'] != null) {
          interviewId = (list.first['id'] as num).toInt();
          state = state.copyWith(interviewId: interviewId);
        }
      } catch (e) {
        debugPrint('[POLL] Error fetching latest interviews: $e');
      }
    }

    if (interviewId == null) {
      debugPrint('[POLL] No interviewId available to poll.');
      _isPolling = false;
      return;
    }

    debugPrint('[POLL] Starting evaluation polling for interview #$interviewId');
    int pollAttempts = 0;
    const maxAttempts = 35; // ~70 seconds at 2-second intervals

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      pollAttempts++;
      if (state.status == InterviewStatus.completed) {
        timer.cancel();
        _isPolling = false;
        return;
      }

      if (pollAttempts > maxAttempts) {
        timer.cancel();
        _isPolling = false;
        if (state.status == InterviewStatus.processing) {
          state = state.copyWith(
            status: InterviewStatus.error,
            errorMessage: 'Evaluation generation timed out. You can retry evaluation below.',
          );
        }
        return;
      }

      try {
        final data = await ApiService.getInterview(token, interviewId!);
        if (data != null) {
          final status = data['status'];
          debugPrint('[POLL] Attempt $pollAttempts: status = $status');
          if (status == 'completed' && data['feedback_json'] != null) {
            timer.cancel();
            _isPolling = false;
            final evaluation = FinalEvaluation.fromJson(data['feedback_json']);
            state = state.copyWith(
              status: InterviewStatus.completed,
              evaluation: evaluation,
              interviewId: interviewId,
            );
          } else if (status == 'error') {
            timer.cancel();
            _isPolling = false;
            state = state.copyWith(
              status: InterviewStatus.error,
              errorMessage: data['feedback_json']?['error'] ?? 'Evaluation failed during processing.',
              interviewId: interviewId,
            );
          }
        }
      } catch (e) {
        debugPrint('[POLL] Attempt $pollAttempts failed with error: $e');
      }
    });
  }

  Future<void> retryEvaluation() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      state = state.copyWith(
        status: InterviewStatus.error,
        errorMessage: 'User not authenticated. Please log in again.',
      );
      return;
    }

    int? interviewId = state.interviewId;
    if (interviewId == null) {
      try {
        final list = await ApiService.getInterviews(token);
        if (list.isNotEmpty && list.first['id'] != null) {
          interviewId = (list.first['id'] as num).toInt();
          state = state.copyWith(interviewId: interviewId);
        }
      } catch (e) {
        debugPrint('Error finding interview to retry: $e');
      }
    }

    if (interviewId == null) {
      state = state.copyWith(
        status: InterviewStatus.error,
        errorMessage: 'No interview record found to retry.',
      );
      return;
    }

    state = state.copyWith(status: InterviewStatus.processing, errorMessage: null);

    final res = await ApiService.retryInterviewEvaluation(token, interviewId);
    if (res != null && (res['status'] == 'processing' || res['status'] == 'completed')) {
      if (res['status'] == 'completed' && res['feedback_json'] != null) {
        final evaluation = FinalEvaluation.fromJson(res['feedback_json']);
        state = state.copyWith(
          status: InterviewStatus.completed,
          evaluation: evaluation,
        );
      } else {
        _isPolling = false;
        pollEvaluation(interviewId);
      }
    } else {
      state = state.copyWith(
        status: InterviewStatus.error,
        errorMessage: res?['detail'] ?? 'Failed to trigger evaluation retry.',
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _isPolling = false;
    // IMPORTANT: Do NOT close _chatChannel if we are still waiting for the backend
    // to send back feedback (InterviewStatus.processing). Closing it will kill the
    // WebSocket before the backend can reply with the end_interview event.
    if (state.status != InterviewStatus.processing) {
      _chatChannel?.sink.close();
    }
    _transcribeChannel?.sink.close();
    _audioStreamSubscription?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _silenceTimer?.cancel();
    super.dispose();
  }
}

// NOT autoDispose — the provider must survive navigating to the processing/evaluation screen
// so the WebSocket stays open to receive the feedback reply from the backend.
final interviewProvider = StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  return InterviewNotifier();
});

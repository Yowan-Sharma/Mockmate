import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/interview_provider.dart';
import '../../data/models/interview_session.dart';

class LiveInterviewScreen extends ConsumerStatefulWidget {
  const LiveInterviewScreen({super.key});

  @override
  ConsumerState<LiveInterviewScreen> createState() => _LiveInterviewScreenState();
}

class _LiveInterviewScreenState extends ConsumerState<LiveInterviewScreen> {
  CameraController? _cameraController;
  final ScrollController _scrollController = ScrollController();
  bool _isCameraInitialized = false;
  bool _isMicActive = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInit();
    
    // Start websocket connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interviewProvider.notifier).startInterview();
    });
  }

  Future<void> _requestPermissionsAndInit() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _initCamera();
    } else {
      // Handle permissions denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera and Microphone permissions are required.')),
        );
      }
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false, // Using record package for audio
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showEndConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Interview?'),
        content: const Text("Are you sure you want to end the interview? Your responses will be analyzed and you'll get a detailed evaluation."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Interview', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(interviewProvider.notifier).endInterview();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
            child: const Text('End Interview', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);

    // Watch for completed status and navigate to evaluation
    ref.listen<InterviewState>(interviewProvider, (previous, next) {
      if ((next.status == InterviewStatus.completed || next.status == InterviewStatus.error) && 
          previous?.status != next.status) {
        context.pushReplacement('/evaluation');
      } else if (next.messages.length != previous?.messages.length) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
      
      if (next.pendingTranscript != previous?.pendingTranscript) {
        if (next.pendingTranscript != null && next.pendingTranscript!.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
        }
      }
    });

    final isCompany = state.company != null && state.company!.isNotEmpty;
    final title = isCompany ? '${state.company} Interview' : '${state.topic ?? 'Topic'} Interview';
    final subtitle = isCompany ? 'Technical • ${state.role ?? 'Software Engineer'}' : 'Topic-Focused Practice';

    if (state.status == InterviewStatus.processing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Analyzing Your Interview',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Reviewing your answers...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _showEndConfirmation,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              onPressed: _showEndConfirmation,
              icon: const Icon(Icons.exit_to_app, size: 18, color: Colors.white),
              label: const Text('End', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Camera Preview Area
          Container(
            height: 240,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (state.isCameraOn && _isCameraInitialized && _cameraController != null)
                  ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 100, // Fixed width, AspectRatio handles the height
                        child: Builder(
                          builder: (context) {
                            final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
                            final ratio = _cameraController!.value.aspectRatio;
                            return AspectRatio(
                              aspectRatio: isPortrait ? (1 / ratio) : ratio,
                              child: CameraPreview(_cameraController!),
                            );
                          }
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                  ),
                
                // Indicators
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.isInterviewerSpeaking ? Icons.graphic_eq : Icons.circle,
                          color: state.isInterviewerSpeaking ? Colors.blue : (state.isListening ? Colors.red : Colors.green),
                          size: state.isInterviewerSpeaking ? 16 : 10,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isInterviewerSpeaking ? 'AI Speaking...' : (state.isListening ? 'Listening...' : 'Ready'),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Camera Controls Overlay
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: state.isCameraOn ? Icons.videocam : Icons.videocam_off,
                        label: 'Camera',
                        onTap: () {
                          ref.read(interviewProvider.notifier).toggleCamera();
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildControlButton(
                        icon: state.isMicOn ? Icons.mic : Icons.mic_off,
                        label: state.isMicOn ? 'Mute' : 'Unmute',
                        color: state.isMicOn ? Colors.white : Colors.red,
                        onTap: () {
                          ref.read(interviewProvider.notifier).toggleMic();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length + ((state.pendingTranscript?.isNotEmpty == true) ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: Text(
                              state.pendingTranscript!,
                              style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF10B981),
                          child: Text('You', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                }

                final msg = state.messages[index];
                final isUser = msg.role == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: const Color(0xFF6366F1),
                          child: const Text('AI', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFFE0E7FF) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isUser ? Colors.transparent : const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            msg.content.isEmpty && !isUser ? '...' : msg.content,
                            style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 12),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF10B981),
                          child: Text('You', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Mic Button Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (_isMicActive) {
                    await ref.read(interviewProvider.notifier).stopRecordingAndSend();
                    setState(() => _isMicActive = false);
                  } else {
                    final success = await ref.read(interviewProvider.notifier).startRecording();
                    if (success) {
                      setState(() => _isMicActive = true);
                    } else {
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Microphone Required'),
                            content: const Text('Please enable microphone access in your device settings to speak your answers.'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  openAppSettings();
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                                child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isMicActive ? Colors.red : const Color(0xFF6366F1).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isMicActive ? Icons.stop : Icons.mic,
                    color: _isMicActive ? Colors.white : const Color(0xFF6366F1),
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

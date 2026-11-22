import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum LoadingMode { appInitialization, postAuthentication }

class LoadingScreen extends ConsumerStatefulWidget {
  final LoadingMode mode;

  const LoadingScreen({super.key, this.mode = LoadingMode.appInitialization});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.mode == LoadingMode.postAuthentication) {
      _runPostAuthInitialization();
    }
  }

  Future<void> _runPostAuthInitialization() async {
    // Simulate real initialization work (e.g. fetching user data, settings, etc.)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPostAuth = widget.mode == LoadingMode.postAuthentication;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEEF2FF), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Icon placeholder
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.school, size: 64, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 32),
            const Text(
              'MockMate',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPostAuth ? 'Getting things ready for you...' : 'Your Personal Interview Coach',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 48),
            if (!isPostAuth) ...[
              const Text(
                'Practice Smarter\nGet Hired Faster',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
            ],
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
            const SizedBox(height: 24),
            if (isPostAuth) ...[
              const _InitializationStep(text: 'Setting up your workspace...', isDone: true),
              const _InitializationStep(text: 'Personalizing your experience...', isDone: true),
              const _InitializationStep(text: 'Loading interview resources...', isDone: false),
            ] else ...[
              const Text(
                'Loading your interview journey...',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _InitializationStep extends StatelessWidget {
  final String text;
  final bool isDone;

  const _InitializationStep({required this.text, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 32.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : const Color(0xFF94A3B8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDone ? const Color(0xFF334155) : const Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

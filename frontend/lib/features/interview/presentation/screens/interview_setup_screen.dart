import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/interview_provider.dart';
import '../../../../services/api_service.dart';

class InterviewSetupScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> extraData;

  const InterviewSetupScreen({super.key, required this.extraData});

  @override
  ConsumerState<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends ConsumerState<InterviewSetupScreen> {
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  String _difficulty = 'Medium';
  
  bool _isResumeLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interviewProvider.notifier).initializeSetup(
        company: widget.extraData['company'],
        topic: widget.extraData['topic'],
        role: widget.extraData['company'] != null ? 'Software Engineer' : null,
        interviewType: widget.extraData['interviewType'],
        interviewMode: widget.extraData['interviewMode'],
        topicId: widget.extraData['topicId'],
      );
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isJd) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isResumeLoading = true;
      });
      
      final text = await ApiService.uploadAndExtractText(result.files.single.path!);
      
      setState(() {
        _isResumeLoading = false;
        if (text != null) _resumeController.text = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);
    final isCompany = state.company != null && state.company!.isNotEmpty;
    final title = isCompany ? '${state.company} Interview' : '${state.topic ?? 'Topic'} Interview';
    final subtitle = isCompany ? 'Technical • ${state.role ?? 'Software Engineer'}' : 'Topic-Focused Practice';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Interview Setup'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Interview Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildDurationInput(),
              const SizedBox(height: 12),
              _buildDifficultyDropdown(),
              
              // Removed Job Description input
              
              const SizedBox(height: 24),
              _buildTextInputWithFileOption(
                label: 'Resume (Optional)',
                hint: 'Paste your resume text here...',
                controller: _resumeController,
                isLoading: _isResumeLoading,
                onPickFile: () => _pickFile(false),
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    int duration = int.tryParse(_durationController.text) ?? 30;
                    ref.read(interviewProvider.notifier).saveSetupData(
                      duration: duration,
                      difficulty: _difficulty,
                      jdText: '',
                      resumeText: _resumeController.text,
                    );
                    context.pushReplacement('/live');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1), // Indigo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Interview →',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputWithFileOption({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isLoading,
    required VoidCallback onPickFile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            TextButton.icon(
              icon: isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.upload_file),
              label: const Text('Upload File'),
              onPressed: isLoading ? null : onPickFile,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          const Text(
            'Duration (mins)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                hintText: 'e.g. 30',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_rounded, color: Color(0xFF64748B)),
          const SizedBox(width: 12),
          const Text(
            'Difficulty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _difficulty,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
              ),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _difficulty = newValue;
                  });
                }
              },
              items: <String>['Low', 'Medium', 'High']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

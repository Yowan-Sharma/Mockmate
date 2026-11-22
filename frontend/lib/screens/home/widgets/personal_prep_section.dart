import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/api_service.dart';
import 'generate_questions_button.dart';

class PersonalPreparationSection extends StatefulWidget {
  const PersonalPreparationSection({super.key});

  @override
  State<PersonalPreparationSection> createState() => _PersonalPreparationSectionState();
}

class _PersonalPreparationSectionState extends State<PersonalPreparationSection> {
  final TextEditingController _resumeController = TextEditingController();
  bool _isResumeLoading = false;
  bool _isGenerating = false;

  @override
  void dispose() {
    _resumeController.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    if (_resumeController.text.trim().isEmpty) {
      _showError('Please provide your resume to continue.');
      return;
    }

    // Navigate to setup screen, passing the selected jd/resume text if needed.
    // Or we can just let them set it up in the setup screen, but here we can pass it as extra data.
    context.push('/setup', extra: {
      'interviewType': 'general',
      'interviewMode': 'personal',
      'topic': 'Personalized Practice',
      'jdText': '',
      'resumeText': _resumeController.text,
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  Future<void> _pickFile() async {
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

  Widget _buildTextInputWithFileOption({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isLoading,
    required VoidCallback onPickFile,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Spacer(),
              TextButton.icon(
                icon: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.upload_file, size: 18),
                label: const Text('Upload File'),
                onPressed: isLoading ? null : onPickFile,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFECFDF5).withOpacity(0.8), // Mint/Green gradient
            const Color(0xFFD1FAE5).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Use Your Own Resume',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get highly relevant interview questions tailored to your background.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          _buildTextInputWithFileOption(
            label: 'Resume',
            hint: 'Paste your resume text here...',
            controller: _resumeController,
            isLoading: _isResumeLoading,
            onPickFile: () => _pickFile(),
          ),
          const SizedBox(height: 24),
          GenerateQuestionsButton(
            isLoading: _isGenerating,
            onPressed: _handleGenerate,
          ),
        ],
      ),
    );
  }
}

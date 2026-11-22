import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/api_service.dart';

class CustomInterviewScreen extends StatefulWidget {
  const CustomInterviewScreen({super.key});

  @override
  State<CustomInterviewScreen> createState() => _CustomInterviewScreenState();
}

enum CustomType { company, topic }

class _CustomInterviewScreenState extends State<CustomInterviewScreen> {
  CustomType _selectedType = CustomType.company;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _resumeController = TextEditingController();
  final TextEditingController _jdController = TextEditingController();

  bool _isResumeLoading = false;
  bool _isJdLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _resumeController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  Future<void> _pickFile(bool isJd) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
    );
    
    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isJd) _isJdLoading = true; else _isResumeLoading = true;
      });
      
      final text = await ApiService.uploadAndExtractText(result.files.single.path!);
      
      setState(() {
        if (isJd) {
          _isJdLoading = false;
          if (text != null) _jdController.text = text;
        } else {
          _isResumeLoading = false;
          if (text != null) _resumeController.text = text;
        }
      });
    }
  }

  void _handleContinue() {
    if (_nameController.text.trim().isEmpty) {
      _showError(_selectedType == CustomType.company ? 'Please provide a company name.' : 'Please provide a topic name.');
      return;
    }

    context.push('/setup', extra: {
      'interviewType': 'general',
      'interviewMode': 'custom',
      'company': _selectedType == CustomType.company ? _nameController.text.trim() : null,
      'topic': _selectedType == CustomType.topic ? _nameController.text.trim() : null,
      'jdText': _jdController.text,
      'resumeText': _resumeController.text,
    });
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Custom Interview'),
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
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Create Your Own Context',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If your target company or topic isn\'t listed, provide details below so we can tailor the interview questions specifically for you.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = CustomType.company),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedType == CustomType.company ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedType == CustomType.company
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Company',
                            style: TextStyle(
                              fontWeight: _selectedType == CustomType.company ? FontWeight.bold : FontWeight.normal,
                              color: _selectedType == CustomType.company ? const Color(0xFF6366F1) : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = CustomType.topic),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedType == CustomType.topic ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedType == CustomType.topic
                                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Topic',
                            style: TextStyle(
                              fontWeight: _selectedType == CustomType.topic ? FontWeight.bold : FontWeight.normal,
                              color: _selectedType == CustomType.topic ? const Color(0xFF6366F1) : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                _selectedType == CustomType.company ? 'Company Name' : 'Topic Name',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: _selectedType == CustomType.company ? 'e.g. Acme Corp' : 'e.g. React Native',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6366F1)),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              _buildTextInputWithFileOption(
                label: 'Resume (Optional)',
                hint: 'Paste your resume text here...',
                controller: _resumeController,
                isLoading: _isResumeLoading,
                onPickFile: () => _pickFile(false),
              ),
              
              const SizedBox(height: 24),
              _buildTextInputWithFileOption(
                label: 'Job Description (Optional)',
                hint: 'Paste the job description here...',
                controller: _jdController,
                isLoading: _isJdLoading,
                onPickFile: () => _pickFile(true),
              ),

              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981), // Emerald green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue to Setup →',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
}

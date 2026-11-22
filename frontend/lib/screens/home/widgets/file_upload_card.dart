import 'package:flutter/material.dart';

class FileUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onUpload;

  const FileUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.fileName,
    this.isLoading = false,
    this.errorMessage,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // light blue
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444), // red
                    ),
                  )
                else if (fileName != null)
                  Text(
                    fileName!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF10B981), // emerald
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                )
              : TextButton(
                  onPressed: onUpload,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFECFDF5), // light emerald
                    foregroundColor: const Color(0xFF10B981), // emerald
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    fileName == null ? 'Choose File' : 'Change',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }
}

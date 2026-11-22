import 'package:flutter/material.dart';

enum PreparationMode { resumeOnly, jdOnly, both }

class PreparationModeSelector extends StatelessWidget {
  final PreparationMode selectedMode;
  final ValueChanged<PreparationMode> onModeChanged;

  const PreparationModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildModeCard(
            context,
            mode: PreparationMode.resumeOnly,
            title: 'Use Resume Only',
            icon: Icons.contact_page,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModeCard(
            context,
            mode: PreparationMode.jdOnly,
            title: 'Use Job Description Only',
            icon: Icons.description,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModeCard(
            context,
            mode: PreparationMode.both,
            title: 'Use Both',
            icon: Icons.post_add,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required PreparationMode mode,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981) : Colors.transparent, // Emerald Green
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? const Color(0xFF10B981) : Colors.grey[500], size: 24),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? const Color(0xFF10B981) : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF064E3B) : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

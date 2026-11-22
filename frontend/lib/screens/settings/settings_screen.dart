import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
            SizedBox(height: 16),
            Text('Manage your MockMate preferences.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

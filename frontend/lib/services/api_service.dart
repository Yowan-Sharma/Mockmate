import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/interview_topic.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator/Web
  static String get baseUrl {
    // Since you are using ADB reverse TCP forwarding, localhost will now correctly resolve 
    // to the Mac host from both iOS and the physical Android device!
    return 'https://myrta-dipterocarpaceous-elsie.ngrok-free.dev/api/v1';
  }

  static Future<List<Company>> getCompanies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/companies'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) return mockCompanies; // Return mock if DB is empty
        
        return data.map((json) {
          // Attempt to map to existing mock data to get logo if it matches
          final existingMock = mockCompanies.cast<Company?>().firstWhere(
            (c) => c!.name.toLowerCase() == json['name'].toString().toLowerCase(),
            orElse: () => null,
          );
          
          return Company(
            id: json['id'].toString(),
            name: json['name'],
            logoUrl: existingMock?.logoUrl ?? 'https://upload.wikimedia.org/wikipedia/commons/a/ac/No_image_available.svg',
            description: existingMock?.description ?? 'Prepare for ${json['name']} interviews.',
            relevance: existingMock?.relevance ?? 1,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching companies: $e');
    }
    return mockCompanies; // fallback
  }

  static Future<List<InterviewTopic>> getTopics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/topics'),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) return mockTopics; // Return mock if DB is empty

        return data.map((json) {
          final existingMock = mockTopics.cast<InterviewTopic?>().firstWhere(
            (t) => t!.name.toLowerCase() == json['name'].toString().toLowerCase(),
            orElse: () => null,
          );

          return InterviewTopic(
            id: json['id'].toString(),
            name: json['name'],
            icon: existingMock?.icon ?? Icons.topic,
            description: existingMock?.description ?? 'Practice ${json['name']} questions.',
            relevance: existingMock?.relevance ?? 1,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Error fetching topics: $e');
    }
    return mockTopics; // fallback
  }
  
  static Future<List<dynamic>> getInterviews(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/interviews/'),
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load past interviews');
  }

  static Future<Map<String, dynamic>?> getInterview(String token, int interviewId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/interviews/$interviewId'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error fetching interview $interviewId: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> retryInterviewEvaluation(String token, int interviewId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/interviews/$interviewId/retry'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error retrying interview evaluation: $e');
    }
    return null;
  }

  static Future<String?> uploadAndExtractText(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      final extension = filePath.split('.').last.toLowerCase();
      if (extension == 'txt') {
         return await file.readAsString();
      }
      
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      
      return text.trim();
    } catch (e) {
      debugPrint('Error extracting text locally: $e');
    }
    return null;
  }
}

import 'package:flutter/material.dart';

class InterviewTopic {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final int relevance;

  const InterviewTopic({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.relevance,
  });
}

final List<InterviewTopic> mockTopics = [
  const InterviewTopic(
    id: 'dsa',
    name: 'Data Structures & Algorithms',
    icon: Icons.account_tree,
    description: 'Common coding questions to test problem-solving skills.',
    relevance: 5,
  ),
  const InterviewTopic(
    id: 'system_design',
    name: 'System Design',
    icon: Icons.architecture,
    description: 'Questions on scalability, architecture and real-world design problems.',
    relevance: 4,
  ),
  const InterviewTopic(
    id: 'behavioral',
    name: 'Behavioral',
    icon: Icons.people,
    description: 'Questions to assess your skills, experiences and cultural fit.',
    relevance: 3,
  ),
  const InterviewTopic(
    id: 'ml',
    name: 'Machine Learning',
    icon: Icons.psychology,
    description: 'Conceptual and applied ML questions for technical roles.',
    relevance: 2,
  ),
  const InterviewTopic(
    id: 'web_dev',
    name: 'Web Development',
    icon: Icons.web,
    description: 'Questions on frontend, backend and full-stack development.',
    relevance: 1,
  ),
];

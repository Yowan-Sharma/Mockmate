import 'package:flutter/material.dart';
import '../../../models/interview_topic.dart';
import '../../../models/sort_option.dart';
import '../../../services/api_service.dart';
import 'section_header.dart';
import 'topic_carousel.dart';

class TopicSection extends StatefulWidget {
  const TopicSection({super.key});

  @override
  State<TopicSection> createState() => _TopicSectionState();
}

class _TopicSectionState extends State<TopicSection> {
  SortOption _currentSort = SortOption.relevance;
  List<InterviewTopic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final topics = await ApiService.getTopics();
    if (mounted) {
      setState(() {
        _topics = topics;
        _isLoading = false;
        _sortTopics(_currentSort);
      });
    }
  }

  void _sortTopics(SortOption sortOption) {
    if (!mounted) return;
    setState(() {
      _currentSort = sortOption;
      switch (sortOption) {
        case SortOption.relevance:
          _topics.sort((a, b) => b.relevance.compareTo(a.relevance));
          break;
        case SortOption.ascending:
          _topics.sort((a, b) => a.name.compareTo(b.name));
          break;
        case SortOption.descending:
          _topics.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Prepare by Topic',
          subtitle: 'Practice questions category-wise to strengthen your skills.',
          icon: Icons.layers,
          iconColor: const Color(0xFF3B82F6), // Blue color
          currentSort: _currentSort,
          onSortChanged: _sortTopics,
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          TopicCarousel(topics: _topics),
      ],
    );
  }
}

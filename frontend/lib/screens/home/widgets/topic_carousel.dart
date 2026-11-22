import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/interview_topic.dart';
import 'topic_card.dart';

class TopicCarousel extends StatelessWidget {
  final List<InterviewTopic> topics;

  const TopicCarousel({
    super.key,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // Fixed height
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return TopicCard(
            topic: topic,
            onTap: () {
              context.push('/setup', extra: {
                'topic': topic.name,
                'topicId': int.tryParse(topic.id),
                'interviewType': 'topic-specific',
                'interviewMode': 'topic',
              });
            },
          );
        },
      ),
    );
  }
}

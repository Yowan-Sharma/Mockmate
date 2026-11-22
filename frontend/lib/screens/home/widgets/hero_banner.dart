import 'package:flutter/material.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'tag': 'PERSONALISED INTERVIEW PREP',
      'title': 'Practice Smarter\nGet Hired Faster',
      'description': 'Tailored interview questions from top companies, key topics, or your own resume and job description.',
      'badges': ['✓ Interview Ready', '✓ Tailored Questions', '✓ Detailed Answers', '✓ Mock Practice'],
      'colors': [const Color(0xFFE0E7FF), const Color(0xFFF3E8FF)],
      'shadow': Colors.purple,
    },
    {
      'tag': 'AI-DRIVEN FEEDBACK',
      'title': 'Analyze Your\nPerformance',
      'description': 'Get actionable insights, score breakdowns, and tips to improve your answers instantly.',
      'badges': ['✓ Instant Score', '✓ Real-time Analysis', '✓ Actionable Tips'],
      'colors': [const Color(0xFFD1FAE5), const Color(0xFFECFDF5)],
      'shadow': Colors.green,
    },
    {
      'tag': 'REALISTIC EXPERIENCE',
      'title': 'Simulate Real\nInterviews',
      'description': 'Experience authentic interview environments with adaptive AI questioning and timing.',
      'badges': ['✓ Voice Enabled', '✓ Adaptive AI', '✓ Stress Tested'],
      'colors': [const Color(0xFFFEF3C7), const Color(0xFFFFFBEB)],
      'shadow': Colors.orange,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 280, // Fixed height to accommodate PageView
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return Container(
                  padding: const EdgeInsets.all(24.0),
                  margin: const EdgeInsets.only(bottom: 12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    gradient: LinearGradient(
                      colors: banner['colors'],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: banner['shadow'].withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        banner['tag'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        banner['title'],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          banner['description'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (banner['badges'] as List<String>)
                            .map((b) => _buildBadge(b))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Carousel indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _banners.length,
              (index) => _buildIndicator(index == _currentPage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6366F1) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

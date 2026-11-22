import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/past_interviews_provider.dart';
import '../../data/models/past_interview.dart';
import '../../../../features/interview/presentation/providers/interview_provider.dart';

class PastInterviewsScreen extends ConsumerStatefulWidget {
  final String? selectedContext; // e.g. "Google" or "System Design"

  const PastInterviewsScreen({super.key, this.selectedContext});

  @override
  ConsumerState<PastInterviewsScreen> createState() => _PastInterviewsScreenState();
}

class _PastInterviewsScreenState extends ConsumerState<PastInterviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pastInterviewsProvider.notifier).fetchInterviews(filterContext: widget.selectedContext);
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(pastInterviewsProvider.notifier).fetchInterviews(filterContext: widget.selectedContext);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pastInterviewsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Past Interviews', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            if (widget.selectedContext != null)
              Text(widget.selectedContext!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF6366F1),
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(PastInterviewsState state) {
    if (state.status == PastInterviewsStatus.loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      );
    }

    if (state.status == PastInterviewsStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Couldn\'t load your past interviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (state.status == PastInterviewsStatus.empty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No past interviews yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Complete your first interview to see your results here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Interview →', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        if (widget.selectedContext == null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Interview History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF312E81))),
                          SizedBox(height: 8),
                          Text('Review your previous interviews and track your progress.', style: TextStyle(color: Color(0xFF4338CA), height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.auto_graph_rounded, size: 48, color: const Color(0xFF6366F1).withValues(alpha: 0.8)),
                  ],
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final interview = state.interviews[index];
                return _buildInterviewCard(interview);
              },
              childCount: state.interviews.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterviewCard(PastInterview interview) {
    final isCompleted = interview.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: isCompleted && interview.feedbackJson != null
            ? () {
                // Populate the existing provider and push evaluation screen
                ref.read(interviewProvider.notifier).loadHistoricalInterview(
                  interview.company,
                  interview.role,
                  interview.feedbackJson!,
                  transcriptJson: interview.transcriptJson,
                );
                context.push('/evaluation');
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(interview.company, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Text(interview.role, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      ],
                    ),
                  ),
                  if (isCompleted && interview.feedbackJson != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Text(
                        '${interview.feedbackJson!.summary.overallScore}/100',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusBadge(interview.status),
                  const Spacer(),
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a').format(interview.createdAt.toLocal()),
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                  if (isCompleted && interview.feedbackJson != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCBD5E1)),
                  ]
                ],
              ),
              if (isCompleted && interview.feedbackJson != null) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    _buildTag(interview.feedbackJson!.summary.hireRecommendation, Colors.blue),
                    const SizedBox(width: 8),
                    _buildTag(interview.feedbackJson!.summary.seniorityAssessment, Colors.purple),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;

    switch (status) {
      case 'completed':
        bgColor = const Color(0xFFF0FDF4); // Green 50
        textColor = const Color(0xFF16A34A); // Green 600
        text = 'Completed';
        break;
      case 'processing':
        bgColor = const Color(0xFFFEFCE8); // Yellow 50
        textColor = const Color(0xFFCA8A04); // Yellow 600
        text = 'Processing';
        icon = Icons.hourglass_top;
        break;
      case 'error':
        bgColor = const Color(0xFFFEF2F2); // Red 50
        textColor = const Color(0xFFDC2626); // Red 600
        text = 'Evaluation Error';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTag(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(color: color.shade700, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 150, height: 20, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            Container(width: 100, height: 16, color: Colors.grey.shade200),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 80, height: 24, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
                Container(width: 120, height: 16, color: Colors.grey.shade200),
              ],
            )
          ],
        ),
      ),
    );
  }
}

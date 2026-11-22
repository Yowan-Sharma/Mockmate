import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/interview_provider.dart';
import '../../data/models/interview_session.dart';

class EvaluationScreen extends ConsumerStatefulWidget {
  const EvaluationScreen({super.key});

  @override
  ConsumerState<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends ConsumerState<EvaluationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);
    final evaluation = state.evaluation;

    if (state.status == InterviewStatus.error) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Interview Results', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Interview Evaluation Issue',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? 'No evaluation could be generated. This may happen if the connection was interrupted or the interview had no responses.',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(interviewProvider.notifier).retryEvaluation();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Retry Evaluation', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Return Home', style: TextStyle(color: Colors.black87, fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (evaluation == null) {
      if (state.status == InterviewStatus.processing) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Analyzing Interview', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.go('/'),
            ),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF6366F1)),
                SizedBox(height: 24),
                Text(
                  'Generating detailed evaluation...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Reviewing your responses and metrics. Please wait...',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Interview Results')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No evaluation data available.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    final isCompany = state.company != null && state.company!.isNotEmpty;
    final title = isCompany ? '${state.company} Interview' : '${state.topic ?? 'Topic'} Interview';
    final subtitle = isCompany ? state.role ?? 'Software Engineer' : 'Topic Practice';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Interview Results', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF6366F1),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Questions'),
            Tab(text: 'Feedback'),
            Tab(text: 'Plan'),
            Tab(text: 'Transcript'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(title, subtitle, evaluation),
          _buildQuestionsTab(evaluation),
          _buildFeedbackTab(evaluation),
          _buildPlanTab(evaluation),
          _buildTranscriptTab(state.messages),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              side: const BorderSide(color: Color(0xFF6366F1)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Another Interview →', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(String title, String subtitle, dynamic evaluation) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),

        // Score Card
        Row(
          children: [
            Expanded(
              child: _buildMetricCard('Overall Score', '${evaluation.summary.overallScore}/100', Colors.blue, isScore: true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _buildMetricCard('Recommendation', evaluation.summary.hireRecommendation, Colors.green),
                  const SizedBox(height: 16),
                  _buildMetricCard('Assessed Level', evaluation.summary.seniorityAssessment, Colors.orange),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const Text('Dimension Scores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDimensionCard('Technical', Icons.code, evaluation.dimensionScores.technicalDepth),
              _buildDimensionCard('Problem Solving', Icons.lightbulb, evaluation.dimensionScores.problemSolving),
              _buildDimensionCard('System Design', Icons.architecture, evaluation.dimensionScores.systemDesign),
              _buildDimensionCard('Communication', Icons.chat, evaluation.dimensionScores.communication),
              _buildDimensionCard('Role Fit', Icons.people, evaluation.dimensionScores.roleFit),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.assignment, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(evaluation.verdict.finalRecommendationText, style: const TextStyle(color: Colors.black87, height: 1.5)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildQuestionsTab(dynamic evaluation) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: evaluation.questionWiseAnalysis.length,
      itemBuilder: (context, index) {
        final q = evaluation.questionWiseAnalysis[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Score: ${q.score}/10', style: const TextStyle(color: Colors.blue)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Answer', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(q.userAnswerSummary, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 12),
                    const Text('Strengths', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ...q.evaluation.strengths.map<Widget>((s) => Text('• $s')).toList(),
                    const SizedBox(height: 12),
                    const Text('Weaknesses', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    ...q.evaluation.weaknesses.map<Widget>((w) => Text('• $w')).toList(),
                    const SizedBox(height: 12),
                    const Text('Ideal Answer Outline', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ...q.evaluation.idealAnswerOutline.map<Widget>((i) => Text('• $i')).toList(),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTab(dynamic evaluation) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Skill Gap Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildListSection('Critical Gaps', evaluation.skillGapAnalysis.criticalGaps, Colors.red),
        _buildListSection('Moderate Gaps', evaluation.skillGapAnalysis.moderateGaps, Colors.orange),
        _buildListSection('Minor Gaps', evaluation.skillGapAnalysis.minorGaps, Colors.amber),
        
        const SizedBox(height: 24),
        const Text('Behavioral Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoCard('Communication Style', evaluation.behavioralInsights.communicationStyle),
        _buildInfoCard('Thinking Pattern', evaluation.behavioralInsights.thinkingPattern),
        _buildInfoCard('Pressure Handling', evaluation.behavioralInsights.pressureHandling),
      ],
    );
  }

  Widget _buildPlanTab(dynamic evaluation) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Improvement Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildListSection('Immediate Actions', evaluation.improvementPlan.immediateActions, Colors.blue),
        _buildListSection('1 Week Plan', evaluation.improvementPlan.plan1Week, Colors.green),
        _buildListSection('1 Month Plan', evaluation.improvementPlan.plan1Month, Colors.purple),
        
        const SizedBox(height: 24),
        const Text('Final Verdict', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildListSection('Strengths to Highlight', evaluation.verdict.strengthsToHighlight, Colors.green),
        _buildListSection('Areas to Fix Before Next Interview', evaluation.verdict.areasToFixBeforeNextInterview, Colors.red),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, {bool isScore = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isScore ? 32 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionCard(String title, IconData icon, int score) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Text('$score/10', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items, Color color) {
    if (items.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            ...items.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(e)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }
  Widget _buildTranscriptTab(List<dynamic> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text('No transcript available.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final isUser = msg.role == 'user';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                const CircleAvatar(
                  backgroundColor: Color(0xFF6366F1),
                  child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFE0E7FF) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isUser ? Colors.transparent : const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    msg.content.isEmpty && !isUser ? '...' : msg.content,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 12),
                const CircleAvatar(
                  backgroundColor: Color(0xFF10B981),
                  child: Text('You', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

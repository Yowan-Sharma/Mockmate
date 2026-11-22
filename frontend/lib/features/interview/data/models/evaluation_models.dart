class FinalEvaluation {
  final Summary summary;
  final DimensionScores dimensionScores;
  final List<QuestionAnalysis> questionWiseAnalysis;
  final SkillGapAnalysis skillGapAnalysis;
  final BehavioralInsights behavioralInsights;
  final ImprovementPlan improvementPlan;
  final Verdict verdict;

  FinalEvaluation({
    required this.summary,
    required this.dimensionScores,
    required this.questionWiseAnalysis,
    required this.skillGapAnalysis,
    required this.behavioralInsights,
    required this.improvementPlan,
    required this.verdict,
  });

  factory FinalEvaluation.fromJson(Map<String, dynamic> json) {
    return FinalEvaluation(
      summary: Summary.fromJson(json['summary'] is Map ? (json['summary'] as Map).cast<String, dynamic>() : {}),
      dimensionScores: DimensionScores.fromJson(json['dimension_scores'] is Map ? (json['dimension_scores'] as Map).cast<String, dynamic>() : {}),
      questionWiseAnalysis: (json['question_wise_analysis'] as List?)
              ?.map((e) => QuestionAnalysis.fromJson(e is Map ? e.cast<String, dynamic>() : {}))
              .toList() ??
          [],
      skillGapAnalysis: SkillGapAnalysis.fromJson(json['skill_gap_analysis'] is Map ? (json['skill_gap_analysis'] as Map).cast<String, dynamic>() : {}),
      behavioralInsights: BehavioralInsights.fromJson(json['behavioral_insights'] is Map ? (json['behavioral_insights'] as Map).cast<String, dynamic>() : {}),
      improvementPlan: ImprovementPlan.fromJson(json['improvement_plan'] is Map ? (json['improvement_plan'] as Map).cast<String, dynamic>() : {}),
      verdict: Verdict.fromJson(json['verdict'] is Map ? (json['verdict'] as Map).cast<String, dynamic>() : {}),
    );
  }
}

class Summary {
  final int overallScore;
  final String hireRecommendation;
  final String seniorityAssessment;
  final String confidenceAssessment;

  Summary({
    required this.overallScore,
    required this.hireRecommendation,
    required this.seniorityAssessment,
    required this.confidenceAssessment,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      overallScore: (json['overall_score'] as num?)?.round() ?? 0,
      hireRecommendation: json['hire_recommendation']?.toString() ?? '',
      seniorityAssessment: json['seniority_assessment']?.toString() ?? '',
      confidenceAssessment: json['confidence_assessment']?.toString() ?? '',
    );
  }
}

class DimensionScores {
  final int technicalDepth;
  final int problemSolving;
  final int systemDesign;
  final int communication;
  final int roleFit;

  DimensionScores({
    required this.technicalDepth,
    required this.problemSolving,
    required this.systemDesign,
    required this.communication,
    required this.roleFit,
  });

  factory DimensionScores.fromJson(Map<String, dynamic> json) {
    return DimensionScores(
      technicalDepth: (json['technical_depth'] as num?)?.round() ?? 0,
      problemSolving: (json['problem_solving'] as num?)?.round() ?? 0,
      systemDesign: (json['system_design'] as num?)?.round() ?? 0,
      communication: (json['communication'] as num?)?.round() ?? 0,
      roleFit: (json['role_fit'] as num?)?.round() ?? 0,
    );
  }
}

class QuestionAnalysis {
  final int questionId;
  final String question;
  final String userAnswerSummary;
  final int score;
  final EvaluationDetail evaluation;

  QuestionAnalysis({
    required this.questionId,
    required this.question,
    required this.userAnswerSummary,
    required this.score,
    required this.evaluation,
  });

  factory QuestionAnalysis.fromJson(Map<String, dynamic> json) {
    return QuestionAnalysis(
      questionId: (json['question_id'] as num?)?.toInt() ?? 0,
      question: json['question']?.toString() ?? '',
      userAnswerSummary: json['user_answer_summary']?.toString() ?? '',
      score: (json['score'] as num?)?.round() ?? 0,
      evaluation: EvaluationDetail.fromJson(json['evaluation'] is Map ? (json['evaluation'] as Map).cast<String, dynamic>() : {}),
    );
  }
}

class EvaluationDetail {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> idealAnswerOutline;

  EvaluationDetail({
    required this.strengths,
    required this.weaknesses,
    required this.idealAnswerOutline,
  });

  factory EvaluationDetail.fromJson(Map<String, dynamic> json) {
    return EvaluationDetail(
      strengths: (json['strengths'] as List?)?.map((e) => e.toString()).toList() ?? [],
      weaknesses: (json['weaknesses'] as List?)?.map((e) => e.toString()).toList() ?? [],
      idealAnswerOutline: (json['ideal_answer_outline'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class SkillGapAnalysis {
  final List<String> criticalGaps;
  final List<String> moderateGaps;
  final List<String> minorGaps;

  SkillGapAnalysis({
    required this.criticalGaps,
    required this.moderateGaps,
    required this.minorGaps,
  });

  factory SkillGapAnalysis.fromJson(Map<String, dynamic> json) {
    return SkillGapAnalysis(
      criticalGaps: (json['critical_gaps'] as List?)?.map((e) => e.toString()).toList() ?? [],
      moderateGaps: (json['moderate_gaps'] as List?)?.map((e) => e.toString()).toList() ?? [],
      minorGaps: (json['minor_gaps'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class BehavioralInsights {
  final String communicationStyle;
  final String thinkingPattern;
  final String pressureHandling;

  BehavioralInsights({
    required this.communicationStyle,
    required this.thinkingPattern,
    required this.pressureHandling,
  });

  factory BehavioralInsights.fromJson(Map<String, dynamic> json) {
    return BehavioralInsights(
      communicationStyle: json['communication_style']?.toString() ?? '',
      thinkingPattern: json['thinking_pattern']?.toString() ?? '',
      pressureHandling: json['pressure_handling']?.toString() ?? '',
    );
  }
}

class ImprovementPlan {
  final List<String> immediateActions;
  final List<String> plan1Week;
  final List<String> plan1Month;

  ImprovementPlan({
    required this.immediateActions,
    required this.plan1Week,
    required this.plan1Month,
  });

  factory ImprovementPlan.fromJson(Map<String, dynamic> json) {
    return ImprovementPlan(
      immediateActions: (json['immediate_actions'] as List?)?.map((e) => e.toString()).toList() ?? [],
      plan1Week: ((json['1_week_plan'] ?? json['plan_1_week']) as List?)?.map((e) => e.toString()).toList() ?? [],
      plan1Month: ((json['1_month_plan'] ?? json['plan_1_month']) as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class Verdict {
  final List<String> strengthsToHighlight;
  final List<String> areasToFixBeforeNextInterview;
  final String finalRecommendationText;

  Verdict({
    required this.strengthsToHighlight,
    required this.areasToFixBeforeNextInterview,
    required this.finalRecommendationText,
  });

  factory Verdict.fromJson(Map<String, dynamic> json) {
    return Verdict(
      strengthsToHighlight: (json['strengths_to_highlight'] as List?)?.map((e) => e.toString()).toList() ?? [],
      areasToFixBeforeNextInterview: (json['areas_to_fix_before_next_interview'] as List?)?.map((e) => e.toString()).toList() ?? [],
      finalRecommendationText: json['final_recommendation_text']?.toString() ?? '',
    );
  }
}

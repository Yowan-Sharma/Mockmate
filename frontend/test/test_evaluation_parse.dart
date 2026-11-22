import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockmate/features/interview/data/models/evaluation_models.dart';

void main() {
  test('FinalEvaluation parse test with int and double scores', () {
    final jsonStr = '''{
  "summary": {
    "overall_score": 85,
    "hire_recommendation": "Hire",
    "seniority_assessment": "Mid-level",
    "confidence_assessment": "High"
  },
  "dimension_scores": {
    "technical_depth": 8,
    "problem_solving": 7,
    "system_design": 8,
    "communication": 9,
    "role_fit": 8
  },
  "question_wise_analysis": [
    {
      "question_id": 1,
      "question": "What is Python?",
      "user_answer_summary": "Explained well",
      "score": 8,
      "evaluation": {
        "strengths": ["Clear"],
        "weaknesses": ["Brief"],
        "ideal_answer_outline": ["Intro"]
      }
    }
  ],
  "skill_gap_analysis": {
    "critical_gaps": [],
    "moderate_gaps": [],
    "minor_gaps": []
  },
  "behavioral_insights": {
    "communication_style": "Concise",
    "thinking_pattern": "Structured",
    "pressure_handling": "Calm"
  },
  "improvement_plan": {
    "immediate_actions": ["Study"],
    "plan_1_week": ["Practice"],
    "plan_1_month": ["Project"]
  },
  "verdict": {
    "strengths_to_highlight": ["Python"],
    "areas_to_fix_before_next_interview": ["Details"],
    "final_recommendation_text": "Good fit"
  }
}''';
    final map = jsonDecode(jsonStr);
    final eval = FinalEvaluation.fromJson(map);
    expect(eval.summary.overallScore, 85);
  });

  test('FinalEvaluation parse with double score (e.g. 8.5) and 1_week_plan alias', () {
    final jsonStr = '''{
  "summary": {
    "overall_score": 85.5,
    "hire_recommendation": "Hire",
    "seniority_assessment": "Mid-level",
    "confidence_assessment": "High"
  },
  "dimension_scores": {
    "technical_depth": 8.0,
    "problem_solving": 7,
    "system_design": 8,
    "communication": 9,
    "role_fit": 8
  },
  "question_wise_analysis": [
    {
      "question_id": 1,
      "question": "What is Python?",
      "user_answer_summary": "Explained well",
      "score": 8.5,
      "evaluation": {
        "strengths": ["Clear"],
        "weaknesses": ["Brief"],
        "ideal_answer_outline": ["Intro"]
      }
    }
  ],
  "skill_gap_analysis": {
    "critical_gaps": [],
    "moderate_gaps": [],
    "minor_gaps": []
  },
  "behavioral_insights": {
    "communication_style": "Concise",
    "thinking_pattern": "Structured",
    "pressure_handling": "Calm"
  },
  "improvement_plan": {
    "immediate_actions": ["Study"],
    "1_week_plan": ["Practice"],
    "1_month_plan": ["Project"]
  },
  "verdict": {
    "strengths_to_highlight": ["Python"],
    "areas_to_fix_before_next_interview": ["Details"],
    "final_recommendation_text": "Good fit"
  }
}''';
    final map = jsonDecode(jsonStr);
    final eval = FinalEvaluation.fromJson(map);
    expect(eval.summary.overallScore, 86);
  });
}

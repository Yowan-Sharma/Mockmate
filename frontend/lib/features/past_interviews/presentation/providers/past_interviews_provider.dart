import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../services/api_service.dart';
import '../../data/models/past_interview.dart';

enum PastInterviewsStatus {
  loading,
  loaded,
  empty,
  error,
}

class PastInterviewsState {
  final PastInterviewsStatus status;
  final List<PastInterview> interviews;
  final String? errorMessage;
  final String? selectedContext; // e.g. "Google" or "System Design"

  PastInterviewsState({
    this.status = PastInterviewsStatus.loading,
    this.interviews = const [],
    this.errorMessage,
    this.selectedContext,
  });

  PastInterviewsState copyWith({
    PastInterviewsStatus? status,
    List<PastInterview>? interviews,
    String? errorMessage,
    String? selectedContext,
  }) {
    return PastInterviewsState(
      status: status ?? this.status,
      interviews: interviews ?? this.interviews,
      errorMessage: errorMessage, // nullable
      selectedContext: selectedContext ?? this.selectedContext,
    );
  }
}

class PastInterviewsNotifier extends StateNotifier<PastInterviewsState> {
  PastInterviewsNotifier() : super(PastInterviewsState());

  Future<void> fetchInterviews({String? filterContext}) async {
    state = state.copyWith(status: PastInterviewsStatus.loading, selectedContext: filterContext);
    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception("User not authenticated");

      final data = await ApiService.getInterviews(token);
      
      List<PastInterview> parsed = [];
      for (var jsonItem in data) {
        try {
          parsed.add(PastInterview.fromJson(jsonItem));
        } catch (parseError) {
          debugPrint('Skipping an interview due to parse error: $parseError');
        }
      }

      // Apply client-side context filtering if provided
      if (filterContext != null && filterContext.isNotEmpty) {
        parsed = parsed.where((i) => i.company.toLowerCase() == filterContext.toLowerCase()).toList();
      }

      if (parsed.isEmpty) {
        state = state.copyWith(status: PastInterviewsStatus.empty, interviews: []);
      } else {
        // Assume backend ordering, if not order by created_at DESC
        parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        state = state.copyWith(status: PastInterviewsStatus.loaded, interviews: parsed);
      }
    } catch (e) {
      state = state.copyWith(status: PastInterviewsStatus.error, errorMessage: e.toString());
    }
  }
}

final pastInterviewsProvider = StateNotifierProvider.autoDispose<PastInterviewsNotifier, PastInterviewsState>((ref) {
  return PastInterviewsNotifier();
});

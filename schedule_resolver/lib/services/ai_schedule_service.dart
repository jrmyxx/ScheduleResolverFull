import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final String _apiKey = 'AIzaSyBIDcP8sf5IETE8inK-IdcamCP9rKFMi_U';

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || tasks.isEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
      final prompt = '''
        You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format: $tasksJson
        
        Your job is to analyze these tasks, identify any overlaps or conflicts in their start and end time and suggest a better balanced schedule.
        Consider their urgency, importance, and required energy level.
      
        Please provide exactly 4 sections of markdown text:
        ### Detected Conflicts
        List any Scheduling conflicts.
        ### Ranked Tasks
        Rank which tasks need attention first based on the urgency, importance and energy. Provide a brief reason on each.
        ### Recommended Schedule
        Provide a revised daily timeline view adjusting the task time.
        ### Explanation
        Explain why this Recommendation was made.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null) {
        _currentAnalysis = _parseResponse(response.text!);
      } else {
        _errorMessage = 'AI returned no response.';
      }
    } catch (e) {
      _errorMessage = 'Failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fullText) {
    String conflicts = "No conflicts detected.";
    String rankedTask = "No tasks ranked.";
    String recommendedSchedule = "No recommendations.";
    String explanation = "No explanation available.";

    final sections = fullText.split('###');

    for (var section in sections) {
      String trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      String lower = trimmed.toLowerCase();
      if (lower.startsWith('detected conflicts')) {
        conflicts = trimmed.replaceFirst(RegExp(r'detected conflicts', caseSensitive: false), '').trim();
      } else if (lower.startsWith('ranked tasks')) {
        rankedTask = trimmed.replaceFirst(RegExp(r'ranked tasks', caseSensitive: false), '').trim();
      } else if (lower.startsWith('recommended schedule')) {
        recommendedSchedule = trimmed.replaceFirst(RegExp(r'recommended schedule', caseSensitive: false), '').trim();
      } else if (lower.startsWith('explanation')) {
        explanation = trimmed.replaceFirst(RegExp(r'explanation', caseSensitive: false), '').trim();
      }
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTask: rankedTask,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);

    final analysis = aiService.currentAnalysis;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Optimized Schedule')),
      body: analysis == null
          ? const Center(child: Text("No recommendations found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Detected Conflicts', analysis.conflicts, Colors.red),
            _buildSection('Ranked Tasks', analysis.rankedTask, Colors.orange),
            _buildSection('Optimized Schedule', analysis.recommendedSchedule, Colors.blue),
            _buildSection('Explanation', analysis.explanation, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
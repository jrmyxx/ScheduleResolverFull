class ScheduleAnalysis {
  final String conflicts;
  final String rankedTask;
  final String recommendedSchedule;
  final String explanation;



  ScheduleAnalysis ({
    required this.conflicts,  required this.explanation, required this.rankedTask, required this.recommendedSchedule
});

}
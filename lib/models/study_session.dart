class StudySession {
  final String id;
  final DateTime date;
  final Duration duration;
  final double avgFocusScore;
  final String dominantEmotion;
  final String videoPath;

  StudySession({
    required this.id,
    required this.date,
    required this.duration,
    required this.avgFocusScore,
    required this.dominantEmotion,
    required this.videoPath,
  });
}

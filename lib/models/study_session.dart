class StudySession {
  final DateTime startTime;
  final int duration;
  final double happy;
  final double neutral;
  final double sad;
  final double tired;

  StudySession({
    required this.startTime,
    required this.duration,
    required this.happy,
    required this.neutral,
    required this.sad,
    required this.tired,
  });

  // Điểm tập trung ước tính (tỷ lệ Happy + Neutral)
  double get avgFocusScore => (happy + neutral) / (happy + neutral + sad + tired);

  // Xác định cảm xúc xuất hiện nhiều nhất
  String get dominantEmotion {
    var emotions = {
      'Hứng thú': happy,
      'Tập trung': neutral,
      'Buồn chán': sad,
      'Mệt mỏi': tired,
    };
    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

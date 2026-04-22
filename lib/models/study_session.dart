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

  // PHIÊN BẢN NÂNG CẤP: Tính điểm tập trung thực tế dựa trên sự hiện diện và chất lượng cảm xúc
  double get avgFocusScore {
    // 1. Tổng số lần nhận diện (mỗi đơn vị tương ứng 15 giây)
    double totalDetectedUnits = happy + neutral + sad + tired;
    
    if (totalDetectedUnits == 0 || duration == 0) return 0.0;

    // 2. Trọng số chất lượng (Quality Score)
    // Tập trung (Neutral) = 100% điểm, Hứng thú (Happy) = 80% điểm
    double qualityScore = (neutral * 1.0 + happy * 0.8) / totalDetectedUnits;

    // 3. Hệ số hiện diện (Presence Factor)
    // Giả sử mỗi lần nhận diện cách nhau 15 giây.
    // Nếu duration tính bằng giây, ta có công thức:
    double secondsDetected = totalDetectedUnits * 15;
    double presenceFactor = secondsDetected / duration;
    
    // Giới hạn presenceFactor tối đa là 1.0 (tránh trường hợp nhận diện nhiều hơn thời gian thực)
    if (presenceFactor > 1.0) presenceFactor = 1.0;

    // Điểm cuối cùng = Chất lượng cảm xúc * Tỉ lệ xuất hiện trước camera
    return (qualityScore * presenceFactor).clamp(0.0, 1.0);
  }

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

import 'dart:math';
import 'package:flutter/material.dart';

/// Mapping cảm xúc → mức độ tập trung
const Map<String, double> emotionWeight = {
  'natural': 1.0,
  'happy': 0.8,
  'surprised': 0.6,
  'sad': 0.4,
  'fear': 0.3,
  'contempt': 0.3,
  'angry': 0.2,
  'disgust': 0.2,
  'sleepy': 0.1,
  'absent': 0.0, // không có mặt
};

/// 1 frame dữ liệu
class FocusFrame {
  final double score;
  final DateTime time;

  FocusFrame(this.score, this.time);
}

/// Bộ tính điểm real-time
class RealTimeFocusScorer {
  final List<FocusFrame> _frames = [];

  /// số giây giữ lại (sliding window)
  final int windowSeconds;

  /// Hệ số smoothing (0-1): cao = mượt hơn, thay đổi chậm hơn
  final double smoothingFactor;

  /// Minimum presence yêu cầu để score có ý nghĩa (0-1)
  final double minPresenceThreshold;

  /// score đã làm mượt
  double _smoothedScore = 0.0;

  RealTimeFocusScorer({
    this.windowSeconds = 30,
    this.smoothingFactor = 0.8,
    this.minPresenceThreshold = 0.3,
  }) : assert(
         smoothingFactor >= 0 && smoothingFactor <= 1,
         'smoothingFactor phải từ 0 đến 1',
       ),
       assert(
         minPresenceThreshold >= 0 && minPresenceThreshold <= 1,
         'minPresenceThreshold phải từ 0 đến 1',
       );

  /// Thêm kết quả từ model (mỗi lần detect)
  void addEmotion(String emotion) {
    final now = DateTime.now();

    double score = emotionWeight[emotion] ?? 0.0;

    _frames.add(FocusFrame(score, now));

    // Xóa dữ liệu cũ
    _frames.removeWhere(
      (f) => now.difference(f.time).inSeconds > windowSeconds,
    );

    // cập nhật smooth
    _updateSmooth();
  }

  /// Thêm kết quả xác suất từ model AI (ví dụ: {natural: 0.6, happy: 0.3, sad: 0.1})
  /// Tính weighted score dựa trên xác suất của mỗi cảm xúc
  void addEmotionProbs(Map<String, double> probs) {
    final now = DateTime.now();

    double score = 0.0;

    probs.forEach((emotion, prob) {
      score += (emotionWeight[emotion] ?? 0.0) * prob;
    });

    _frames.add(FocusFrame(score, now));

    _frames.removeWhere(
      (f) => now.difference(f.time).inSeconds > windowSeconds,
    );

    _updateSmooth();
  }

  /// Trung bình raw (không xét presence)
  double get currentScore {
    if (_frames.isEmpty) return 0.0;

    double sum = _frames.fold(0.0, (a, b) => a + b.score);
    return (sum / _frames.length).clamp(0.0, 1.0);
  }

  /// Presence: % thời gian có mặt trước camera
  double get presence {
    if (_frames.isEmpty) return 0.0;

    int valid = _frames.where((f) => f.score > 0.2).length;
    return valid / _frames.length;
  }

  /// Score cuối cùng (raw)
  /// Nếu presence < minPresenceThreshold, return 0 (không có mặt đủ)
  double get finalScore {
    if (presence < minPresenceThreshold) return 0.0;

    // giảm ảnh hưởng của presence
    return (currentScore * 0.7 + presence * 0.3).clamp(0.0, 1.0);
  }

  /// Score mượt (dùng cho UI)
  double get smoothScore => _smoothedScore;

  /// Lấy trạng thái text cho UI
  String getStatusText() {
    if (_frames.isEmpty) return "Chưa bật camera";
    if (presence < minPresenceThreshold) return "Vắng mặt";

    if (_smoothedScore > 0.7) return "Tập trung tốt 🔥";
    if (_smoothedScore > 0.5) return "Tập trung bình ⚡";
    return "Cần chú ý ⚠️";
  }

  /// Lấy trạng thái chi tiết
  (String, Color) getStatusWithColor() {
    if (_frames.isEmpty) return ("Chưa bật camera", Colors.grey);
    if (presence < minPresenceThreshold) return ("Vắng mặt", Colors.grey);

    if (_smoothedScore > 0.7) return ("Tập trung tốt", Colors.green);
    if (_smoothedScore > 0.5) return ("Tập trung bình", Colors.yellow);
    return ("Cần chú ý", Colors.red);
  }

  /// Lấy màu dựa trên score
  Color getStatusColor() {
    if (_smoothedScore > 0.7) return Colors.green;
    if (_smoothedScore > 0.5) return Colors.yellow;
    return Colors.red;
  }

  /// Lấy thống kê session
  Map<String, dynamic> getStats() {
    return {
      'frameCount': _frames.length,
      'currentScore': (currentScore * 100).toInt(),
      'presence': (presence * 100).toInt(),
      'finalScore': (finalScore * 100).toInt(),
      'smoothScore': (smoothScore * 100).toInt(),
      'status': getStatusText(),
    };
  }

  /// Làm mượt tránh giật (EMA smoothing)
  void _updateSmooth() {
    double raw = finalScore;

    // EMA: smoothed = smoothed * α + raw * (1-α)
    _smoothedScore =
        _smoothedScore * smoothingFactor + raw * (1 - smoothingFactor);
  }

  /// Reset session
  void reset() {
    _frames.clear();
    _smoothedScore = 0.0;
  }
}

/// Model đại diện cho 1 buổi học tập
class StudySession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // phút
  final double avgFocusScore; // 0.0 - 1.0
  final String dominantEmotion;
  final Map<String, int> emotionFrequency; // emotion -> count
  final String? videoPath;
  final int totalFrames;

  StudySession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.avgFocusScore,
    required this.dominantEmotion,
    required this.emotionFrequency,
    this.videoPath,
    this.totalFrames = 0,
  });

  /// Tính thời gian kết thúc
  DateTime get computedEndTime =>
      endTime ?? startTime.add(Duration(minutes: duration));

  /// Format thời gian học
  String get formattedTime {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return "$hours giờ $minutes phút";
    }
    return "$minutes phút";
  }

  /// Format ngày tháng
  String get formattedDate {
    return "${startTime.day}/${startTime.month}/${startTime.year}";
  }

  /// Trạng thái mức độ tập trung
  String get focusStatus {
    if (avgFocusScore > 0.7) return "Tập trung tốt 🔥";
    if (avgFocusScore > 0.5) return "Tập trung bình ⚡";
    return "Cần cải thiện ⚠️";
  }

  /// Màu trạng thái
  Color get focusColor {
    if (avgFocusScore > 0.7) return Colors.green;
    if (avgFocusScore > 0.5) return Colors.yellow;
    return Colors.red;
  }

  /// Phân bố cảm xúc (tỉ lệ phần trăm) - dùng cho chart/UI
  /// Ví dụ: {'natural': 0.7, 'happy': 0.2, 'sad': 0.1}
  Map<String, double> get emotionDistribution {
    final total = emotionFrequency.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );

    if (total == 0) return {};

    return emotionFrequency.map(
      (emotion, count) => MapEntry(emotion, count / total),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'avgFocusScore': avgFocusScore,
      'dominantEmotion': dominantEmotion,
      'emotionFrequency': emotionFrequency,
      'videoPath': videoPath,
      'totalFrames': totalFrames,
    };
  }

  /// Create from JSON
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] ?? '',
      startTime: DateTime.parse(
        json['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      duration: json['duration'] ?? 0,
      avgFocusScore: (json['avgFocusScore'] as num?)?.toDouble() ?? 0.0,
      dominantEmotion: json['dominantEmotion'] ?? 'unknown',
      emotionFrequency: Map<String, int>.from(json['emotionFrequency'] ?? {}),
      videoPath: json['videoPath'],
      totalFrames: json['totalFrames'] ?? 0,
    );
  }
}

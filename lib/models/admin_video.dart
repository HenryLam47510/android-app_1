class AdminVideo {
  final String id;
  final String filename;
  final Duration duration;
  final DateTime createdAt;
  final String status; // 'raw' or 'processed'
  final String videoUrl;
  final List<VideoSegment> segments;
  final List<AiResult> aiResults;

  AdminVideo({
    required this.id,
    required this.filename,
    required this.duration,
    required this.createdAt,
    required this.status,
    required this.videoUrl,
    required this.segments,
    required this.aiResults,
  });

  factory AdminVideo.fromJson(Map<String, dynamic> json) {
    return AdminVideo(
      id: json['id'].toString(),
      filename: json['file_path'] ?? json['filename'] ?? '',
      duration: Duration(seconds: (json['duration'] ?? 0) as int),
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'unknown',
      videoUrl: json['file_path'] ?? '',
      segments: [],
      aiResults: [],
    );
  }
}

class VideoSegment {
  final String id;
  final int segmentNumber;
  final Duration startTime;
  final Duration endTime;
  final String status;

  VideoSegment({
    required this.id,
    required this.segmentNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
  });
}

class AiResult {
  final String timestamp;
  final String emotion;

  AiResult({required this.timestamp, required this.emotion});
}

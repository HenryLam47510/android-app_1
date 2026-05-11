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
    final segmentsJson = json['segments'] as List<dynamic>?;
    return AdminVideo(
      id: json['id'].toString(),
      filename: json['file_path'] ?? json['filename'] ?? '',
      duration: Duration(seconds: (json['duration'] ?? 0) as int),
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'unknown',
      videoUrl: json['file_path'] ?? '',
      segments: segmentsJson != null
          ? segmentsJson
                .map(
                  (item) =>
                      VideoSegment.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : [],
      aiResults: [],
    );
  }
}

class VideoSegment {
  final String id;
  final int segmentNumber;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final String status;
  final String filePath;

  VideoSegment({
    required this.id,
    required this.segmentNumber,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    required this.filePath,
  });

  factory VideoSegment.fromJson(Map<String, dynamic> json) {
    return VideoSegment(
      id: json['id'].toString(),
      segmentNumber: json['segment_number'] is int
          ? json['segment_number']
          : int.tryParse(json['segment_number'].toString()) ?? 0,
      startTime: DateTime.parse(json['start_time'].toString()),
      endTime: DateTime.parse(json['end_time'].toString()),
      duration: Duration(
        seconds: json['duration'] is int
            ? json['duration']
            : int.tryParse(json['duration'].toString()) ?? 0,
      ),
      status: json['status'] ?? 'recorded',
      filePath: json['file_path'] ?? '',
    );
  }
}

class AiResult {
  final String timestamp;
  final String emotion;

  AiResult({required this.timestamp, required this.emotion});
}

class FrameEmotion {
  final int id;
  final String emotion;
  final double confidence;
  final DateTime timestamp;
  final String? imagePath;
  final bool stateChange;
  final String? previousEmotion;

  FrameEmotion({
    required this.id,
    required this.emotion,
    required this.confidence,
    required this.timestamp,
    this.imagePath,
    required this.stateChange,
    this.previousEmotion,
  });

  factory FrameEmotion.fromJson(Map<String, dynamic> json) {
    return FrameEmotion(
      id: json['id'] as int,
      emotion: json['emotion'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['image_path'] as String?,
      stateChange: json['state_change'] as bool,
      previousEmotion: json['previous_emotion'] as String?,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'study_session.dart';
import 'package:path/path.dart' as path;

class StudySegment {
  final String id;
  final int number;
  final XFile file;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;

  StudySegment({
    required this.id,
    required this.number,
    required this.file,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
  });

  String get filePath => file.path;
}

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  int _recordingCountdown = 0;
  Timer? _countdownTimer;

  DateTime? _segmentStartTime;
  int _segmentCount = 0;
  int? _videoSessionId;
  final List<StudySegment> _segments = [];

  // Kết quả phân tích
  Map<String, dynamic>? _analysisResult;
  RealTimeFocusScorer? _focusScorer;

  // API
  final Dio _dio = Dio();

  /// Backend URL - có thể cấu hình
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    // Android emulator
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    // iOS simulator
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      setState(() => _cameras = cameras);

      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('Lỗi khởi tạo camera: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khởi tạo camera: $e')));
    }
  }

  Future<void> _toggleRecording() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      if (_isRecording) {
        final videoFile = await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordingCountdown = 0;
        });

        final segmentEnd = DateTime.now();
        final start = _segmentStartTime ?? segmentEnd;
        final durationSeconds = segmentEnd.difference(start).inSeconds;
        _segmentCount += 1;
        final segment = StudySegment(
          id: 'seg_${_segmentCount}',
          number: _segmentCount,
          file: videoFile,
          startTime: start,
          endTime: segmentEnd,
          durationSeconds: durationSeconds,
        );

        setState(() {
          _segments.add(segment);
        });

        await _uploadSegment(segment);
      } else {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _segmentStartTime = DateTime.now();
          _recordingCountdown = 0;
        });
      }
    } catch (e) {
      print('Lỗi quay video: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi quay video: $e')));
    }
  }

  Future<void> _uploadSegment(StudySegment segment) async {
    setState(() => _isAnalyzing = true);
    try {
      final fileBytes = await segment.file.readAsBytes();
      final formData = FormData.fromMap({
        'user_id': 2,
        'segment_number': segment.number,
        'start_time': segment.startTime.toIso8601String(),
        'end_time': segment.endTime.toIso8601String(),
        'status': 'recorded',
        if (_videoSessionId != null) 'video_id': _videoSessionId,
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: path.basename(segment.filePath),
        ),
      });

      final response = await _dio.post(
        '$_backendUrl/upload_segment',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['video_id'] != null) {
          _videoSessionId =
              int.tryParse(data['video_id'].toString()) ?? _videoSessionId;
        }

        if (data['analysis'] != null) {
          final analysis = data['analysis'];
          _analysisResult = {
            'concentrationScore': analysis['concentration_score'] ?? 0.0,
            'focusStatus': analysis['focus_status'] ?? 'Unknown',
            'focusEmoji': analysis['focus_emoji'] ?? '❓',
            'dominantEmotion': analysis['dominant_emotion'] ?? 'neutral',
            'emotionBreakdown': analysis['emotion_breakdown'] ?? {},
            'frameCount': analysis['frame_count'] ?? 0,
            'videoPath': segment.filePath,
          };

          _showResultDialog();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload segment thành công')),
        );
      } else {
        throw Exception('Upload segment thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi upload segment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi upload segment: $e')));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showResultDialog() {
    if (_analysisResult == null) return;

    final score = (_analysisResult!['concentrationScore'] as num).toDouble();
    final status = _analysisResult!['focusStatus'] as String;
    final emoji = _analysisResult!['focusEmoji'] as String;
    final emotion = _analysisResult!['dominantEmotion'] as String;

    Color statusColor = Colors.grey;

    if (score > 0.7) {
      statusColor = Colors.green;
    } else if (score > 0.5) {
      statusColor = Colors.amber;
    } else {
      statusColor = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết quả phân tích'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  Text(
                    '${(score * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cảm xúc chính: $emotion',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tổng frame: ${_analysisResult!['frameCount']}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phân tích chi tiết:',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._buildEmotionBreakdown(),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetAndRecord();
            },
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEmotionBreakdown() {
    final breakdown =
        _analysisResult!['emotionBreakdown'] as Map<String, dynamic>;
    if (breakdown.isEmpty) {
      return [const Text('Không có dữ liệu', style: TextStyle(fontSize: 12))];
    }

    return breakdown.entries
        .map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 12)),
                Text(
                  '${(e.value as num).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _resetAndRecord() {
    setState(() {
      _analysisResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích tập trung'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Camera preview
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isRecording
                    ? SizedBox(
                        height: 300,
                        child: CameraPreview(_cameraController!),
                      )
                    : Container(
                        height: 300,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.videocam,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
              ),
            ),

            // Recording state
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: const [
                    Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Đang ghi đoạn video...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else if (_isAnalyzing)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'Đang phân tích...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 32),

            // Analysis result
            if (_analysisResult != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kết quả',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${((_analysisResult!['concentrationScore'] as num) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('Tập trung'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              _analysisResult!['focusStatus'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text('Trạng thái'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            if (_segments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh sách đoạn đã ghi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._segments.map(
                      (segment) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(segment.number.toString()),
                          ),
                          title: Text(
                            'Đoạn ${segment.number} • ${segment.durationSeconds}s',
                          ),
                          subtitle: Text(
                            '${segment.startTime.hour.toString().padLeft(2, '0')}:${segment.startTime.minute.toString().padLeft(2, '0')} - ${segment.endTime.hour.toString().padLeft(2, '0')}:${segment.endTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // Record button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    _isRecording ? 'Dừng ghi đoạn' : 'Bắt đầu ghi đoạn',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }
}

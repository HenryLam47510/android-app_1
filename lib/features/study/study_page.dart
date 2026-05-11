import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'study_session.dart';
import 'package:path/path.dart' as path;

class StudyCapture {
  final String id;
  final int number;
  final XFile file;
  final DateTime timestamp;
  final String label;
  final double focusLevel;
  final double confidence;
  final bool saved;
  final String? backendPath;
  final String? message;

  StudyCapture({
    required this.id,
    required this.number,
    required this.file,
    required this.timestamp,
    required this.label,
    required this.focusLevel,
    required this.confidence,
    required this.saved,
    this.backendPath,
    this.message,
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
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  Timer? _captureTimer;
  int _captureCount = 0;
  final List<StudyCapture> _captures = [];

  // Kết quả phân tích
  Map<String, dynamic>? _analysisResult;

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

  Future<void> _toggleCapture() async {
    if (!_cameraController!.value.isInitialized) return;

    try {
      if (_isCapturing) {
        _stopCapture();
      } else {
        _startCapture();
      }
    } catch (e) {
      print('Lỗi chụp ảnh: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
    }
  }

  void _startCapture() {
    setState(() {
      _isCapturing = true;
      _isAnalyzing = false;
      _captureCount = 0;
      _analysisResult = null;
      _captures.clear();
    });

    _captureFrame();
    _captureTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _captureFrame();
    });
  }

  void _stopCapture() {
    _captureTimer?.cancel();
    _captureTimer = null;
    setState(() {
      _isCapturing = false;
    });
  }

  Future<void> _captureFrame() async {
    if (!_cameraController!.value.isInitialized) return;
    setState(() => _isAnalyzing = true);

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final timestamp = DateTime.now().toIso8601String();
      final response = await ApiService.analyzeFrame(
        imageFile,
        userId: 2,
        timestamp: timestamp,
      );

      final label = response['emotion']?.toString() ?? 'neutral';
      final focusLevel = (response['confidence'] as num?)?.toDouble() ?? 0.5;
      final confidence = (response['confidence'] as num?)?.toDouble() ?? 0.0;
      final saved = response['saved_image'] == true;
        final message = data['message']?.toString();
        final backendPath = data['file_path']?.toString();

        _captureCount += 1;
        final capture = StudyCapture(
          id: 'cap_${_captureCount}',
          number: _captureCount,
          file: imageFile,
          timestamp: DateTime.parse(timestamp),
          label: label,
          focusLevel: focusLevel,
          confidence: confidence,
          saved: saved,
          backendPath: backendPath,
          message: message,
        );

        setState(() {
          _captures.insert(0, capture);
          _analysisResult = {
            'focusLevel': focusLevel,
            'label': label,
            'confidence': confidence,
            'saved': saved,
            'message': message,
            'backendPath': backendPath,
            'timestamp': timestamp,
          };
        });

        if (saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ảnh ${_captureCount} đã lưu: $label')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bỏ qua ảnh trùng trạng thái: $label')),
          );
        }
      } else {
        throw Exception('Upload frame thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi upload frame: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi upload frame: $e')));
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
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
                child: SizedBox(
                  height: 300,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

            // Recording state
            if (_isCapturing)
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
                      'Đang chụp ảnh tự động...',
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
                              '${((_analysisResult!['focusLevel'] as num) * 100).toStringAsFixed(0)}%',
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
                              _analysisResult!['label']?.toString() ??
                                  'neutral',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text('Biểu cảm'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Độ tin cậy: ${(((_analysisResult!['confidence'] as num?)?.toDouble() ?? 0.0) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    if (_analysisResult!['message'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _analysisResult!['message'].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (_captures.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danh sách ảnh đã gửi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._captures.map(
                      (capture) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(capture.number.toString()),
                          ),
                          title: Text(
                            'Ảnh ${capture.number} • ${capture.label}',
                          ),
                          subtitle: Text(
                            '${capture.timestamp.hour.toString().padLeft(2, '0')}:${capture.timestamp.minute.toString().padLeft(2, '0')}:${capture.timestamp.second.toString().padLeft(2, '0')} • ${capture.saved ? 'Đã lưu' : 'Bỏ qua'}',
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
                  onPressed: _isAnalyzing ? null : _toggleCapture,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(
                    _isCapturing ? 'Dừng chụp ảnh' : 'Bắt đầu chụp ảnh',
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
}

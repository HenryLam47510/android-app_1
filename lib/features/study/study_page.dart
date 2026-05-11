import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../../data/remote/api_service.dart';

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
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  Timer? _captureTimer;
  int _captureCount = 0;
  final List<StudyCapture> _captures = [];

  // Kết quả phân tích
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

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
      final message = response['message']?.toString();
      final backendPath = response['file_path']?.toString();

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

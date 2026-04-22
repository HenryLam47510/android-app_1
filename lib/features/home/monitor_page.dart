import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../data/remote/api_service.dart';

class MonitorPage extends StatefulWidget {
  final bool isMonitoring;
  final CameraController? controller;
  final VoidCallback onToggle;

  const MonitorPage({
    super.key,
    required this.isMonitoring,
    this.controller,
    required this.onToggle,
  });

  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  double _focusLevel = 0.5; // Giá trị mặc định 50%
  Timer? _timer;

  @override
  void didUpdateWidget(MonitorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu bắt đầu quay video, kích hoạt timer mỗi 15s
    if (widget.isMonitoring && !oldWidget.isMonitoring) {
      _startAITracking();
    } else if (!widget.isMonitoring && oldWidget.isMonitoring) {
      _stopAITracking();
    }
  }

  @override
  void dispose() {
    _stopAITracking();
    super.dispose();
  }

  void _startAITracking() {
    // Chạy ngay lần đầu tiên
    _runAIPrediction();
    // Sau đó lặp lại mỗi 15 giây
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _runAIPrediction();
    });
  }

  void _stopAITracking() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _runAIPrediction() async {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return;
    }

    try {
      // 1. Chụp ảnh màn hình từ camera (ngầm)
      final XFile image = await widget.controller!.takePicture();

      // 2. Gửi ảnh lên Backend AI và nhận % tập trung
      final double result = await ApiService.predictFocus(image.path);

      // 3. Cập nhật thanh tiến độ
      if (mounted) {
        setState(() {
          _focusLevel = result;
        });
      }
    } catch (e) {
      print("Lỗi nhận diện AI: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Study Monitor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue, // Màu xanh cho học sinh
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6, // Tăng lên 60% màn hình cho camera
            child: Container(
              margin: const EdgeInsets.all(8), // Giảm margin
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(
                  16,
                ), // Giảm borderRadius, rectangle hơn
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isMonitoring &&
                      widget.controller != null &&
                      widget.controller!.value.isInitialized)
                    CameraPreview(widget.controller!)
                  else
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_front_outlined,
                          size: 80,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Camera chưa bật",
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),

                  // Badge trạng thái nổi bật
                  Positioned(top: 16, left: 16, child: _buildStatusBadge()),
                ],
              ),
            ),
          ),
          // Nút to hơn, nằm ngay dưới camera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 60, // To hơn
              child: ElevatedButton.icon(
                onPressed: widget.onToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isMonitoring
                      ? Colors.redAccent
                      : Colors.lightBlue, // Màu xanh cho học sinh
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4, // Nổi bật hơn
                ),
                icon: Icon(
                  widget.isMonitoring ? Icons.stop : Icons.play_arrow,
                  size: 28, // Icon lớn hơn
                ),
                label: Text(
                  widget.isMonitoring
                      ? "Kết thúc buổi học"
                      : "Bắt đầu học ngay",
                  style: const TextStyle(
                    fontSize: 18, // Text lớn hơn
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4, // Giảm flex cho controls
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStatusCard(widget.isMonitoring),
                  const SizedBox(height: 20),
                  _buildFocusIndicator(widget.isMonitoring),
                  const SizedBox(height: 24),
                  _buildAISuggestion(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    String statusText;
    Color bgColor;
    IconData icon;

    if (widget.isMonitoring) {
      if (_focusLevel > 0) {
        statusText = "Đang phân tích";
        bgColor = Colors.orange;
        icon = Icons.psychology;
      } else {
        statusText = "Đang theo dõi";
        bgColor = Colors.green;
        icon = Icons.visibility;
      }
    } else {
      statusText = "Chưa bật camera";
      bgColor = Colors.grey;
      icon = Icons.camera_alt;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool monitoring) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.psychology_outlined, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Phân tích AI",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Text(
                  monitoring ? "Đang theo dõi..." : "Sẵn sàng",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (monitoring)
              Text(
                _focusLevel > 0.7 ? "🔥 Tập trung tốt" : "⚠️ Cần chú ý",
                style: TextStyle(
                  color: _focusLevel > 0.7 ? Colors.orange : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusIndicator(bool monitoring) {
    Color progressColor;
    if (_focusLevel > 0.7) {
      progressColor = Colors.green; // Tốt
    } else if (_focusLevel > 0.5) {
      progressColor = Colors.yellow; // Trung bình
    } else {
      progressColor = Colors.red; // Kém
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Mức độ tập trung",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "${(_focusLevel * 100).toInt()}%",
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: monitoring ? _focusLevel : 0,
          minHeight: 16, // Lớn hơn
          borderRadius: BorderRadius.circular(8),
          color: progressColor,
          backgroundColor: Colors.grey.withOpacity(0.2),
        ),
        const SizedBox(height: 4),
        const Text(
          "Cập nhật mỗi 15 giây",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAISuggestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.tips_and_updates, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Hệ thống sẽ dựa trên biểu cảm để nhắc nhở tư thế và độ tập trung của bạn.",
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

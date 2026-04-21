import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class MonitorPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Study Monitor", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.black87, 
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Camera Preview
                  if (isMonitoring && controller != null && controller!.value.isInitialized)
                    CameraPreview(controller!)
                  else
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_front_outlined, size: 80, color: Colors.white24),
                        SizedBox(height: 12),
                        Text("Camera chưa bật", style: TextStyle(color: Colors.white38)),
                      ],
                    ),
                  
                  // REC Badge khi đang học
                  if (isMonitoring)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildLiveBadge(),
                    ),
                  
                  // Nút Start/Stop study nằm trên Preview
                  Positioned(
                    bottom: 24,
                    child: ElevatedButton.icon(
                      onPressed: onToggle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMonitoring ? Colors.redAccent : Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      icon: Icon(isMonitoring ? Icons.stop : Icons.play_arrow),
                      label: Text(isMonitoring ? "Kết thúc buổi học" : "Bắt đầu học ngay"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStatusCard(isMonitoring),
                  const SizedBox(height: 20),
                  _buildFocusIndicator(isMonitoring),
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

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text("REC", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool monitoring) {
    return Card(
      elevation: 0,
      color: Colors.indigo.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.indigo.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.face_retouching_natural, size: 32, color: Colors.indigo),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Cảm xúc (AI)", style: TextStyle(fontSize: 13, color: Colors.grey)),
                // 4. Emotion detection demo
                Text(monitoring ? "Đang tập trung" : "---", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            if (monitoring) const Text("🔥 Cực tốt", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusIndicator(bool monitoring) {
    double score = 0.85;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Độ tập trung", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${(score * 100).toInt()}%", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: monitoring ? score : 0,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
          color: Colors.indigo,
          backgroundColor: Colors.indigo.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildAISuggestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: const [
          Icon(Icons.tips_and_updates, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(child: Text("AI khuyên bạn: Tư thế ngồi đang hơi cúi, hãy điều chỉnh lại nhé!", style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

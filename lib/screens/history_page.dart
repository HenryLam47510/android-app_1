import 'package:flutter/material.dart';
import '../models/study_session.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StudySession> sessions = [
      StudySession(id: "1", date: DateTime.now(), duration: const Duration(minutes: 45), avgFocusScore: 0.88, dominantEmotion: "Tập trung", videoPath: "/videos/1.mp4"),
      StudySession(id: "2", date: DateTime.now().subtract(const Duration(days: 1)), duration: const Duration(minutes: 30), avgFocusScore: 0.65, dominantEmotion: "Mệt mỏi", videoPath: "/videos/2.mp4"),
      StudySession(id: "3", date: DateTime.now().subtract(const Duration(days: 2)), duration: const Duration(hours: 1, minutes: 20), avgFocusScore: 0.92, dominantEmotion: "Hứng thú", videoPath: "/videos/3.mp4"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử học tập", style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final s = sessions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.play_circle_fill, color: Colors.indigo, size: 30),
              ),
              title: Text("Buổi học ${s.date.day}/${s.date.month}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Thời lượng: ${s.duration.inMinutes} phút • Cảm xúc: ${s.dominantEmotion}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${(s.avgFocusScore * 100).toInt()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const Text("Điểm", style: TextStyle(fontSize: 10)),
                ],
              ),
              onTap: () {
                // Điều hướng tới trang báo cáo (có thể tạo thêm file report_page.dart nếu cần)
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Nhắc nhở buổi học",
        "body": "Đã đến giờ học môn Toán rồi, bắt đầu thôi nào!",
        "time": "10 phút trước",
        "icon": Icons.alarm,
        "color": Colors.orange
      },
      {
        "title": "Thành tích mới",
        "body": "Chúc mừng! Bạn đã duy trì tập trung trên 90% trong 3 buổi liên tiếp.",
        "time": "2 giờ trước",
        "icon": Icons.emoji_events,
        "color": Colors.amber
      },
      {
        "title": "Lời khuyên từ AI",
        "body": "Dựa trên lịch sử, bạn thường tập trung tốt nhất vào lúc 8h sáng.",
        "time": "1 ngày trước",
        "icon": Icons.auto_awesome,
        "color": Colors.indigo
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (n['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(n['icon'], color: n['color'], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(n['body'], style: const TextStyle(color: Colors.black87, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(n['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

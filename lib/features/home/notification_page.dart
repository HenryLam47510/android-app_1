import 'package:flutter/material.dart';
import '../../constants/app_state.dart';
import '../../data/remote/api_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    final userId = currentUserNotifier.value.id > 0
        ? currentUserNotifier.value.id
        : 1;
    setState(() {
      _notificationsFuture = ApiService.getNotifications(userId: userId);
    });
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await ApiService.markNotificationRead(notificationId);
    if (success) {
      _refreshNotifications();
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'new':
        return 'Mới xảy ra';
      case 'frequent':
        return 'Xảy ra thường xuyên trong ngày';
      case 'trend':
        return 'Lặp lại nhiều ngày liên tiếp';
      default:
        return 'Thông báo học tập';
    }
  }

  IconData _categoryIcon(String? category) {
    switch (category) {
      case 'low_concentration':
        return Icons.warning_amber_rounded;
      case 'fatigue':
        return Icons.bedtime;
      case 'negative_emotion':
        return Icons.mood_bad;
      case 'good_focus':
        return Icons.thumb_up_alt;
      case 'overstudy':
        return Icons.timer;
      case 'camera':
      case 'system':
        return Icons.camera_alt_outlined;
      default:
        return Icons.notifications;
    }
  }

  Color _categoryColor(String? category) {
    switch (category) {
      case 'low_concentration':
        return Colors.orange;
      case 'fatigue':
        return Colors.deepPurple;
      case 'negative_emotion':
        return Colors.redAccent;
      case 'good_focus':
        return Colors.green;
      case 'overstudy':
        return Colors.blue;
      case 'camera':
      case 'system':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNotifications,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Lỗi tải thông báo. Vui lòng thử lại.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshNotifications,
                    child: const Text('Tải lại'),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có thông báo nào.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hệ thống sẽ gửi cảnh báo học tập khi có tín hiệu mới.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final item = notifications[index];
              final isRead = item['is_read'] == true;
              final statusText = _statusLabel(item['status'] as String?);
              final iconColor = _categoryColor(item['category'] as String?);
              final createdAt = item['created_at'] as String? ?? '';

              return Card(
                elevation: isRead ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isRead ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.16),
                    child: Icon(
                      _categoryIcon(item['category'] as String?),
                      color: iconColor,
                    ),
                  ),
                  title: Text(
                    item['title']?.toString() ?? '',
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(item['message']?.toString() ?? ''),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            statusText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (createdAt.isNotEmpty) ...[
                            const Icon(
                              Icons.circle,
                              size: 4,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              createdAt,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(isRead ? Icons.done : Icons.mark_email_unread),
                    color: isRead ? Colors.green : Colors.blue,
                    tooltip: isRead ? 'Đã đọc' : 'Đánh dấu đã đọc',
                    onPressed: isRead
                        ? null
                        : () => _markAsRead(item['id'] as int),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

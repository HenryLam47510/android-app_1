import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';

class AdminUserDailyStatsPage extends StatefulWidget {
  const AdminUserDailyStatsPage({super.key});

  @override
  State<AdminUserDailyStatsPage> createState() =>
      _AdminUserDailyStatsPageState();
}

class _AdminUserDailyStatsPageState extends State<AdminUserDailyStatsPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  late Future<List<Map<String, dynamic>>> _statsFuture;
  int? _selectedUserId;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAdminUsers();
    _statsFuture = Future.value([]);
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture
        .then((users) {
          if (!mounted) return;
          if (users.isNotEmpty) {
            setState(() {
              _selectedUserId = users.first['id'] as int;
              _statsFuture = ApiService.getAdminUserDailyStats(
                userId: _selectedUserId,
                date: _selectedDate,
              );
            });
          }
        })
        .catchError((_) {});
  }

  void _refreshStats() {
    if (_selectedUserId == null) return;
    setState(() {
      _statsFuture = ApiService.getAdminUserDailyStats(
        userId: _selectedUserId,
        date: _selectedDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê ảnh theo user/ngày'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Text('Không có tài khoản để hiển thị.');
                }
                return DropdownButtonFormField<int>(
                  value: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Chọn tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  items: users.map((user) {
                    return DropdownMenuItem<int>(
                      value: user['id'] as int,
                      child: Text(
                        user['name'] ?? user['email'] ?? 'Người dùng',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedUserId = value;
                      _statsFuture = ApiService.getAdminUserDailyStats(
                        userId: _selectedUserId,
                      );
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshStats,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tải lại số liệu'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _statsFuture = ApiService.getAdminUserDailyStats(
                          userId: _selectedUserId,
                          date: _selectedDate,
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Chọn ngày'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ngày hiện tại: ${_selectedDate.toIso8601String().split('T')[0]}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stats = snapshot.data ?? [];
                  if (stats.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có dữ liệu thống kê cho tài khoản này.',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: stats.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = stats[index];
                      final recordDate = item['record_date']?.toString() ?? '';
                      return ListTile(
                        title: Text(recordDate),
                        subtitle: Text(
                          'Khung hình: ${item['total_frames']} • Ảnh lưu: ${item['saved_images']}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

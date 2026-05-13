import 'dart:math';

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
    _statsFuture = ApiService.getAdminUserDailyStats(date: _selectedDate);
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture.catchError((_) {});
  }

  void _refreshStats() {
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
                return DropdownButtonFormField<int?>(
                  value: _selectedUserId,
                  decoration: const InputDecoration(
                    labelText: 'Chọn tài khoản',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Tất cả tài khoản'),
                    ),
                    ...users.map((user) {
                      return DropdownMenuItem<int?>(
                        value: user['id'] as int,
                        child: Text(
                          user['name'] ?? user['email'] ?? 'Người dùng',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserId = value;
                      _statsFuture = ApiService.getAdminUserDailyStats(
                        userId: _selectedUserId,
                        date: _selectedDate,
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
                      child: Text('Không có dữ liệu thống kê cho ngày này.'),
                    );
                  }
                  final grouped = _groupStatsByUser(stats);
                  final userEntries = grouped.entries.toList()
                    ..sort((a, b) {
                      final aName = a.value
                          .map((item) => item['name']?.toString() ?? '')
                          .firstWhere(
                            (name) => name.isNotEmpty,
                            orElse: () => '',
                          );
                      final bName = b.value
                          .map((item) => item['name']?.toString() ?? '')
                          .firstWhere(
                            (name) => name.isNotEmpty,
                            orElse: () => '',
                          );
                      return aName.compareTo(bName);
                    });
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: userEntries.map((entry) {
                        final userId = entry.key;
                        final userStats = entry.value;
                        final aggregated = _aggregateEmotionCounts(userStats);
                        final userName =
                            aggregated['name'] ?? 'Người dùng $userId';
                        final recordDate =
                            aggregated['record_date']?.toString() ??
                            _selectedDate.toIso8601String().split('T')[0];
                        final totalFrames =
                            aggregated['total_frames'] as int? ?? 0;
                        final savedImages =
                            aggregated['saved_images'] as int? ?? 0;
                        final emotionCounts = Map<String, int>.from(
                          aggregated['emotion_counts'] as Map<String, int>? ??
                              {},
                        );
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Ngày: $recordDate'),
                              const SizedBox(height: 8),
                              Text('Tổng khung hình: $totalFrames'),
                              Text('Ảnh lưu: $savedImages'),
                              const SizedBox(height: 16),
                              const Text(
                                'Thống kê cảm xúc',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (emotionCounts.isEmpty)
                                const Center(
                                  child: Text(
                                    'Không có dữ liệu cảm xúc cho ngày này.',
                                  ),
                                )
                              else
                                _buildEmotionBarChart(emotionCounts),
                              const SizedBox(height: 16),
                              const Text(
                                'Chi tiết theo cảm xúc',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...emotionCounts.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key.capitalize()),
                                      Text(entry.value.toString()),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _aggregateEmotionCounts(
    List<Map<String, dynamic>> stats,
  ) {
    final emotionCounts = <String, int>{};
    String? recordDate;
    String? name;
    int totalFrames = 0;
    int savedImages = 0;

    for (final item in stats) {
      name ??= item['name']?.toString();
      recordDate ??= item['record_date']?.toString();
      final emotion = item['emotion']?.toString() ?? 'unknown';
      final count = item['emotion_count'] is int
          ? item['emotion_count'] as int
          : int.tryParse(item['emotion_count']?.toString() ?? '0') ?? 0;
      emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + count;
      totalFrames += count;
      savedImages = max(
        savedImages,
        item['saved_images'] is int
            ? item['saved_images'] as int
            : int.tryParse(item['saved_images']?.toString() ?? '0') ?? 0,
      );
    }

    return {
      'record_date': recordDate,
      'name': name,
      'total_frames': totalFrames,
      'saved_images': savedImages,
      'emotion_counts': emotionCounts,
    };
  }

  Map<int, List<Map<String, dynamic>>> _groupStatsByUser(
    List<Map<String, dynamic>> stats,
  ) {
    final grouped = <int, List<Map<String, dynamic>>>{};
    for (final item in stats) {
      final userId = item['user_id'] is int
          ? item['user_id'] as int
          : int.tryParse(item['user_id']?.toString() ?? '') ?? 0;
      grouped.putIfAbsent(userId, () => []).add(item);
    }
    return grouped;
  }

  Widget _buildEmotionBarChart(Map<String, int> counts) {
    final maxCount = counts.values.fold<int>(
      0,
      (prev, value) => max(prev, value),
    );
    final colors = {
      'happy': Colors.green,
      'sad': Colors.blue,
      'neutral': Colors.grey,
      'angry': Colors.redAccent,
      'surprised': Colors.orange,
      'unknown': Colors.indigo,
    };
    final keys = counts.keys.toList()
      ..sort((a, b) {
        const order = [
          'happy',
          'sad',
          'neutral',
          'angry',
          'surprised',
          'unknown',
        ];
        final ai = order.indexOf(a);
        final bi = order.indexOf(b);
        return ai.compareTo(bi);
      });

    return SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((emotion) {
          final count = counts[emotion] ?? 0;
          final barHeight = maxCount > 0 ? (count / maxCount) * 140.0 : 0.0;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(count.toString()),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 32,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: colors[emotion] ?? Colors.indigo,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 60,
                child: Text(
                  emotion.capitalize(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';

class AdminEmotionTimelinePage extends StatefulWidget {
  const AdminEmotionTimelinePage({super.key});

  @override
  State<AdminEmotionTimelinePage> createState() =>
      _AdminEmotionTimelinePageState();
}

class _AdminEmotionTimelinePageState extends State<AdminEmotionTimelinePage> {
  late Future<List<Map<String, dynamic>>> _timelineFuture;
  late Future<List<Map<String, dynamic>>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _users = [];
  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAdminUsers();
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture
        .then((users) {
          if (!mounted) return;
          setState(() {
            _users = users;
            _selectedUserId = users.isNotEmpty
                ? users.first['id'] as int
                : null;
            _loadTimeline();
          });
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() {
            _users = [];
          });
        });
  }

  void _loadTimeline() {
    if (_selectedUserId == null) {
      return;
    }
    setState(() {
      _timelineFuture = ApiService.getEmotionTimeline(
        _selectedUserId!,
        date: _selectedDate,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _groupByHour(List<Map<String, dynamic>> frames) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final frame in frames) {
      final timestamp = DateTime.parse(frame['timestamp']);
      final hourKey = '${timestamp.hour.toString().padLeft(2, '0')}:00';
      final emotion = frame['emotion'] as String;

      if (!grouped.containsKey(hourKey)) {
        grouped[hourKey] = {
          'hour': hourKey,
          'emotions': <String, Map<String, dynamic>>{},
          'snapshots': <Map<String, dynamic>>[],
        };
      }

      if (!grouped[hourKey]!['emotions'].containsKey(emotion)) {
        grouped[hourKey]!['emotions'][emotion] = {
          'count': 0,
          'frames': <Map<String, dynamic>>[],
        };
      }

      grouped[hourKey]!['emotions'][emotion]['count'] += 1;
      grouped[hourKey]!['emotions'][emotion]['frames'].add(frame);

      if (frame['image_path'] != null) {
        grouped[hourKey]!['snapshots'].add(frame);
      }
    }

    return grouped.values.toList()
      ..sort((a, b) => b['hour'].compareTo(a['hour']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Timeline Cảm Xúc"),
        actions: [
          IconButton(onPressed: _loadTimeline, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
                _loadTimeline();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _usersFuture,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                );
              }
              final users = userSnapshot.data ?? [];
              if (users.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Không có tài khoản để hiển thị timeline.'),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: DropdownButtonFormField<int>(
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
                    });
                    _loadTimeline();
                  },
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _timelineFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final frames = snapshot.data ?? [];
                final groupedData = _groupByHour(frames);

                if (groupedData.isEmpty) {
                  return const Center(
                    child: Text('Không có dữ liệu cảm xúc cho ngày này'),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: groupedData.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final hourData = groupedData[index];
                          final emotions =
                              hourData['emotions'] as Map<String, dynamic>;
                          final snapshots =
                              hourData['snapshots']
                                  as List<Map<String, dynamic>>;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                hourData['hour'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                emotions.keys
                                    .map((emotion) {
                                      final count = emotions[emotion]['count'];
                                      return '$emotion (x$count)';
                                    })
                                    .join(', '),
                              ),
                              children: [
                                if (snapshots.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Snapshots:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshots.length,
                                      itemBuilder: (context, snapIndex) {
                                        final snapshot = snapshots[snapIndex];
                                        return GestureDetector(
                                          onTap: () => _showSnapshotDialog(
                                            context,
                                            snapshot,
                                          ),
                                          child: Container(
                                            width: 80,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.image,
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  snapshot['emotion'],
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                Text(
                                                  DateTime.parse(
                                                        snapshot['timestamp'],
                                                      )
                                                      .toString()
                                                      .split(' ')[1]
                                                      .substring(0, 5),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSnapshotDialog(
    BuildContext context,
    Map<String, dynamic> snapshot,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Snapshot - ${snapshot['emotion']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Thời gian: ${DateTime.parse(snapshot['timestamp'])}"),
            Text(
              "Confidence: ${(snapshot['confidence'] * 100).toStringAsFixed(1)}%",
            ),
            if (snapshot['previous_emotion'] != null)
              Text("Trước đó: ${snapshot['previous_emotion']}"),
            Text("State Change: ${snapshot['state_change'] ? 'Có' : 'Không'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

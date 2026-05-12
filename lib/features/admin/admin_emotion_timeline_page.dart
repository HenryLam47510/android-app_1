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
    _timelineFuture = Future.value([]);
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

  List<Map<String, dynamic>> _groupByTimeBucket(
    List<Map<String, dynamic>> frames,
  ) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final frame in frames) {
      final timestamp = DateTime.parse(frame['timestamp']);
      final bucketStart = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
        timestamp.hour,
        (timestamp.minute ~/ 10) * 10,
      );
      final bucketKey =
          '${bucketStart.hour.toString().padLeft(2, '0')}:${bucketStart.minute.toString().padLeft(2, '0')}';
      final emotion = frame['emotion'] as String;

      if (!grouped.containsKey(bucketKey)) {
        grouped[bucketKey] = {
          'bucket': bucketKey,
          'emotions': <String, Map<String, dynamic>>{},
          'snapshots': <Map<String, dynamic>>[],
        };
      }

      if (!grouped[bucketKey]!['emotions'].containsKey(emotion)) {
        grouped[bucketKey]!['emotions'][emotion] = {
          'count': 0,
          'frames': <Map<String, dynamic>>[],
        };
      }

      grouped[bucketKey]!['emotions'][emotion]['count'] += 1;
      grouped[bucketKey]!['emotions'][emotion]['frames'].add(frame);

      if (frame['image_url'] != null) {
        grouped[bucketKey]!['snapshots'].add(frame);
      }
    }

    return grouped.values.toList()
      ..sort((a, b) => b['bucket'].compareTo(a['bucket']));
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
                final groupedData = _groupByTimeBucket(frames);

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
                                hourData['bucket'] as String? ?? 'Không rõ',
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
                                            width: 100,
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                  8,
                                                                ),
                                                            topRight:
                                                                Radius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                      color: Colors.grey[200],
                                                    ),
                                                    child:
                                                        snapshot['image_url'] !=
                                                            null
                                                        ? Image.network(
                                                            snapshot['image_url']
                                                                as String,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return const Center(
                                                                    child: Icon(
                                                                      Icons
                                                                          .broken_image,
                                                                      size: 28,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  );
                                                                },
                                                          )
                                                        : const Center(
                                                            child: Icon(
                                                              Icons.image,
                                                              size: 32,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    6.0,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        snapshot['emotion']
                                                                ?.toString() ??
                                                            'Không rõ',
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
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
            Text(
              "State Change: ${snapshot['state_change'] == true ? 'Có' : 'Không'}",
            ),
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

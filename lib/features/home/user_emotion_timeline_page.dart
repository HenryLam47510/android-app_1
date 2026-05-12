import 'package:flutter/material.dart';
import '../../constants/app_state.dart';
import '../../data/remote/api_service.dart';

class UserEmotionTimelinePage extends StatefulWidget {
  const UserEmotionTimelinePage({super.key});

  @override
  State<UserEmotionTimelinePage> createState() =>
      _UserEmotionTimelinePageState();
}

class _UserEmotionTimelinePageState extends State<UserEmotionTimelinePage> {
  late Future<List<Map<String, dynamic>>> _timelineFuture;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshTimeline();
  }

  void _refreshTimeline() {
    final userId = currentUserNotifier.value.id > 0
        ? currentUserNotifier.value.id
        : 1;
    setState(() {
      _timelineFuture = ApiService.getEmotionTimeline(
        userId,
        date: _selectedDate,
      );
    });
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
        title: const Text('Timeline Cảm Xúc của bạn'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshTimeline,
            icon: const Icon(Icons.refresh),
          ),
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
                _refreshTimeline();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _timelineFuture,
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
                  const Text('Lỗi tải dữ liệu. Vui lòng kiểm tra server.'),
                  TextButton(
                    onPressed: _refreshTimeline,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final frames = snapshot.data ?? [];
          final groupedData = _groupByTimeBucket(frames);

          if (groupedData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timeline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có dữ liệu timeline cho ngày này',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy bật camera và học để thu thập dữ liệu.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: groupedData.length,
                  itemBuilder: (context, index) {
                    final bucketData = groupedData[index];
                    final emotions =
                        bucketData['emotions'] as Map<String, dynamic>;
                    final snapshots =
                        bucketData['snapshots'] as List<Map<String, dynamic>>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          bucketData['bucket'],
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshots.length,
                                itemBuilder: (context, snapIndex) {
                                  final snapshot = snapshots[snapIndex];
                                  return GestureDetector(
                                    onTap: () =>
                                        _showSnapshotDialog(context, snapshot),
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        8,
                                                      ),
                                                      topRight: Radius.circular(
                                                        8,
                                                      ),
                                                    ),
                                                color: Colors.grey[200],
                                              ),
                                              child:
                                                  snapshot['image_url'] != null
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
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            );
                                                          },
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 32,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  snapshot['emotion'],
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
    );
  }

  void _showSnapshotDialog(
    BuildContext context,
    Map<String, dynamic> snapshot,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Snapshot - ${snapshot['emotion']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thời gian: ${DateTime.parse(snapshot['timestamp'])}'),
            Text(
              'Confidence: ${(snapshot['confidence'] * 100).toStringAsFixed(1)}%',
            ),
            if (snapshot['previous_emotion'] != null)
              Text('Trước đó: ${snapshot['previous_emotion']}'),
            Text('State Change: ${snapshot['state_change'] ? 'Có' : 'Không'}'),
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

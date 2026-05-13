import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/remote/api_service.dart';

class AdminMonitorReportsPage extends StatefulWidget {
  const AdminMonitorReportsPage({super.key});

  @override
  State<AdminMonitorReportsPage> createState() =>
      _AdminMonitorReportsPageState();
}

class _AdminMonitorReportsPageState extends State<AdminMonitorReportsPage> {
  late Future<List<Map<String, dynamic>>> _reportsFuture;
  String _selectedSource = 'all';
  final TextEditingController _userIdController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadReports();
  }

  Future<List<Map<String, dynamic>>> _loadReports() async {
    final userIdText = _userIdController.text.trim();
    final userId = int.tryParse(userIdText);
    final source = _selectedSource != 'all' ? _selectedSource : null;

    return ApiService.getMonitorAwayReports(
      userId: userId,
      source: source,
      date: _selectedDate,
    );
  }

  Future<void> _refreshReports() async {
    final future = _loadReports();
    setState(() {
      _reportsFuture = future;
    });
    await future;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Không có thời gian';
    try {
      final parsed = DateTime.parse(timestamp).toLocal();
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo rời camera'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final reports = await _reportsFuture;
              await _showExportCsvDialog(reports);
            },
            tooltip: 'Xuất CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi tải báo cáo: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final reports = snapshot.data ?? [];
          final originalReports = reports;
          if (reports.isEmpty) {
            return const Center(child: Text('Chưa có báo cáo rời camera nào.'));
          }

          final backgroundCount = originalReports
              .where((item) => item['source'] == 'background')
              .length;
          final tabCount = originalReports
              .where((item) => item['source'] == 'tab')
              .length;
          final longestAway = originalReports
              .map((item) => item['away_seconds'] as int? ?? 0)
              .fold<int>(0, (prev, value) => value > prev ? value : prev);

          return RefreshIndicator(
            onRefresh: () async => _refreshReports(),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng quan báo cáo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildSummaryChip(
                              'Tổng báo cáo',
                              originalReports.length.toString(),
                            ),
                            _buildSummaryChip('Tab', tabCount.toString()),
                            _buildSummaryChip(
                              'Background',
                              backgroundCount.toString(),
                            ),
                            _buildSummaryChip(
                              'Lần away lâu nhất',
                              '${longestAway}s',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _userIdController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Lọc theo User ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<String>(
                          value: _selectedSource,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Tất cả nguồn'),
                            ),
                            DropdownMenuItem(value: 'tab', child: Text('Tab')),
                            DropdownMenuItem(
                              value: 'background',
                              child: Text('Background'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSource = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _pickDate,
                            child: Text(
                              _selectedDate == null
                                  ? 'Chọn ngày lọc'
                                  : 'Ngày: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {});
                            await _refreshReports();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                          ),
                          child: const Text('Áp dụng'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSource = 'all';
                              _userIdController.clear();
                              _selectedDate = null;
                              _reportsFuture = _loadReports();
                            });
                          },
                          child: const Text('Xóa bộ lọc'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text('Không tìm thấy báo cáo phù hợp.'),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = reports[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatTimestamp(item['timestamp']?.toString()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'User: ${item['user_name'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'User ID: ${item['user_id'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Khoảng thời gian rời: ${item['away_seconds'] ?? '-'} giây',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nguồn: ${item['source'] ?? '-'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (item['note'] != null &&
                                  item['note'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Ghi chú: ${item['note']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _showNoteDialog(
                                        context,
                                        index,
                                        item['note']?.toString() ?? '',
                                      );
                                    },
                                    icon: const Icon(Icons.note_add),
                                    label: const Text('Ghi chú'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showExportCsvDialog(List<Map<String, dynamic>> reports) async {
    final csvHeader = 'Timestamp,User,User ID,Away seconds,Source,Note';
    final csvRows = reports
        .map((item) {
          final timestamp =
              item['timestamp']?.toString().replaceAll(',', ' ') ?? '';
          final userName =
              item['user_name']?.toString().replaceAll(',', ' ') ?? '';
          final userId = item['user_id']?.toString() ?? '';
          final awaySeconds = item['away_seconds']?.toString() ?? '';
          final source = item['source']?.toString().replaceAll(',', ' ') ?? '';
          final note = item['note']?.toString().replaceAll(',', ' ') ?? '';
          return '$timestamp,$userName,$userId,$awaySeconds,$source,$note';
        })
        .join('\n');
    final csvContent = '$csvHeader\n$csvRows';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV báo cáo'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: Text(csvContent)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('CSV đã được sao chép vào clipboard'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Sao chép'),
          ),
        ],
      ),
    );
  }

  Future<void> _showNoteDialog(
    BuildContext context,
    int reportIndex,
    String currentNote,
  ) async {
    final noteController = TextEditingController(text: currentNote);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm/Sửa ghi chú'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ApiService.updateMonitorReportNote(
                reportIndex,
                noteController.text,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
                await _refreshReports();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cập nhật ghi chú thành công')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật ghi chú thất bại'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    noteController.dispose();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Widget _buildSummaryChip(String label, String value) {
    return Chip(
      backgroundColor: Colors.indigo.shade50,
      label: Text('$label: $value', style: const TextStyle(fontSize: 12)),
    );
  }
}

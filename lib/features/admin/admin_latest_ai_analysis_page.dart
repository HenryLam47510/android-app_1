import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';

class AdminLatestAiAnalysisPage extends StatefulWidget {
  const AdminLatestAiAnalysisPage({super.key});

  @override
  State<AdminLatestAiAnalysisPage> createState() =>
      _AdminLatestAiAnalysisPageState();
}

class _AdminLatestAiAnalysisPageState extends State<AdminLatestAiAnalysisPage> {
  late Future<List<Map<String, dynamic>>> _analysesFuture;
  late Future<List<Map<String, dynamic>>> _usersFuture;
  List<Map<String, dynamic>> _users = [];
  int? _selectedUserId;
  DateTime _selectedDate = DateTime.now();
  int _selectedIndex = 0;

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
          });
          _loadAnalyses();
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() {
            _users = [];
            _selectedUserId = null;
            _analysesFuture = Future.value([]);
          });
        });
  }

  void _loadAnalyses() {
    if (_selectedUserId == null) {
      setState(() {
        _analysesFuture = Future.value([]);
      });
      return;
    }
    setState(() {
      _selectedIndex = 0;
      _analysesFuture = ApiService.getAdminLatestAiAnalyses(
        userId: _selectedUserId,
        date: _selectedDate,
        limit: 100,
      );
    });
  }

  void _selectAnalysis(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickDate() async {
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
      _loadAnalyses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết AI Phân tích'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _usersFuture,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: LinearProgressIndicator(),
                  );
                }
                final users = userSnapshot.data ?? [];
                if (users.isEmpty) {
                  return const Text('Không có tài khoản học sinh để hiển thị.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedUserId,
                            decoration: const InputDecoration(
                              labelText: 'Chọn tài khoản học sinh',
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
                              _loadAnalyses();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Chọn ngày'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _analysesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final analyses = snapshot.data ?? [];
                  if (analyses.isEmpty) {
                    return const Center(
                      child: Text(
                        'Không có ảnh nhận diện được của học sinh này trong ngày đã chọn.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final selected = analyses[_selectedIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected['name']?.toString() ??
                            'Học sinh không xác định',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey.shade200,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: selected['image_url'] != null
                            ? Image.network(
                                selected['image_url'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 54,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Giá trị phân tích ảnh',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailLine(
                                'Cảm xúc',
                                selected['emotion']?.toString() ?? 'Không rõ',
                              ),
                              _buildDetailLine(
                                'Độ tin cậy',
                                selected['confidence'] != null
                                    ? '${((selected['confidence'] as num).toDouble() * 100).toStringAsFixed(1)}%'
                                    : 'Không rõ',
                              ),
                              _buildDetailLine(
                                'Thời gian',
                                selected['timestamp']?.toString() ?? 'Không có',
                              ),
                              _buildDetailLine(
                                'Trạng thái chuyển đổi',
                                selected['state_change'] == true
                                    ? 'Có'
                                    : 'Không',
                              ),
                              if (selected['previous_emotion'] != null)
                                _buildDetailLine(
                                  'Cảm xúc trước',
                                  selected['previous_emotion']?.toString() ??
                                      '',
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tất cả ảnh đã nhận diện trong ngày',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 8,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                            itemCount: analyses.length,
                            itemBuilder: (context, index) {
                              final item = analyses[index];
                              return GestureDetector(
                                onTap: () => _selectAnalysis(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: index == _selectedIndex
                                          ? Colors.indigo
                                          : Colors.grey.shade300,
                                      width: index == _selectedIndex ? 2 : 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: item['image_url'] != null
                                      ? Image.network(
                                          item['image_url'] as String,
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

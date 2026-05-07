import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';
import '../../models/admin_video.dart';
import 'admin_video_detail_page.dart';

class AdminVideoListPage extends StatefulWidget {
  const AdminVideoListPage({super.key});

  @override
  State<AdminVideoListPage> createState() => _AdminVideoListPageState();
}

class _AdminVideoListPageState extends State<AdminVideoListPage> {
  late Future<List<AdminVideo>> _videosFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _videosFuture = ApiService.getAdminVideos();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _videosFuture = ApiService.getAdminVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý Video"),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<AdminVideo>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final videos = snapshot.data ?? [];
          final filteredVideos = _searchQuery.isEmpty
              ? videos
              : videos.where((video) {
                  final lowerQuery = _searchQuery.toLowerCase();
                  return video.filename.toLowerCase().contains(lowerQuery) ||
                      video.status.toLowerCase().contains(lowerQuery) ||
                      video.createdAt.toString().contains(lowerQuery);
                }).toList();

          if (filteredVideos.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Không tìm thấy video phù hợp với "$_searchQuery".',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Tìm kiếm theo tên / trạng thái / ngày',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('Hôm nay'),
                    _buildFilterChip('Lớp AI01'),
                    _buildFilterChip('Sinh viên'),
                    _buildFilterChip('Chưa xử lý'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredVideos.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final video = filteredVideos[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.video_collection,
                          color: Colors.blue,
                        ),
                        title: Text(
                          video.filename,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${video.duration.inMinutes} phút • ${video.createdAt.day}/${video.createdAt.month}",
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: video.status == "processed"
                                ? Colors.green
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            video.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminVideoDetailPage(video: video),
                          ),
                        ),
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

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          setState(() {
            _searchController.text = label;
          });
        },
      ),
    );
  }
}

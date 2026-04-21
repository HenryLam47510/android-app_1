import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/admin_video.dart';
import 'admin_video_detail_page.dart';

class AdminVideoListPage extends StatefulWidget {
  const AdminVideoListPage({super.key});

  @override
  State<AdminVideoListPage> createState() => _AdminVideoListPageState();
}

class _AdminVideoListPageState extends State<AdminVideoListPage> {
  late Future<List<AdminVideo>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = ApiService.getAdminVideos();
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
          if (videos.isEmpty) {
            return const Center(child: Text("Không có video nào."));
          }

          return ListView.builder(
            itemCount: videos.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.video_collection, color: Colors.blue),
                  title: Text(video.filename, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Text("${video.duration.inMinutes} phút • ${video.createdAt.day}/${video.createdAt.month}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: video.status == "processed" ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      video.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminVideoDetailPage(video: video)),
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

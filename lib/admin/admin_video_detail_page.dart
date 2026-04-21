import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/admin_video.dart';
import '../../api/api_service.dart';

class AdminVideoDetailPage extends StatefulWidget {
  final AdminVideo video;
  const AdminVideoDetailPage({super.key, required this.video});

  @override
  State<AdminVideoDetailPage> createState() => _AdminVideoDetailPageState();
}

class _AdminVideoDetailPageState extends State<AdminVideoDetailPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.video.videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
        ..initialize().then((_) {
          setState(() {
            _isInitialized = true;
          });
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _deleteVideo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa video?"),
        content: const Text("Bạn có chắc chắn muốn xóa video này và toàn bộ dữ liệu liên quan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiService.deleteVideo(widget.video.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết Video"),
        actions: [
          IconButton(onPressed: _deleteVideo, icon: const Icon(Icons.delete_outline, color: Colors.red)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.black,
              child: _isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                        IconButton(
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white.withOpacity(0.8),
                            size: 64,
                          ),
                          onPressed: () {
                            setState(() {
                              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                            });
                          },
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.video.filename, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Trạng thái: ${widget.video.status.toUpperCase()}", style: TextStyle(color: widget.video.status == "processed" ? Colors.green : Colors.orange)),
                  const Divider(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Phân đoạn (Segments)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${widget.video.segments.length} đoạn", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.video.segments.map((seg) => ListTile(
                        leading: CircleAvatar(child: Text(seg.segmentNumber.toString())),
                        title: Text("Đoạn ${seg.startTime.inSeconds}s - ${seg.endTime.inSeconds}s"),
                        subtitle: Text("Trạng thái: ${seg.status}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          onPressed: () => ApiService.deleteSegment(seg.id),
                        ),
                      )),

                  const SizedBox(height: 32),
                  const Text("Kết quả phân tích AI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.video.aiResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final res = widget.video.aiResults[index];
                        return ListTile(
                          leading: const Icon(Icons.access_time, size: 20),
                          title: Text(res.timestamp, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(res.emotion, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

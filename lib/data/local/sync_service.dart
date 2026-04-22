import 'package:dio/dio.dart';
import '../../models/video_sync_item.dart';
import 'database_service.dart';

class SyncService {
  final Dio _dio = Dio(
    BaseOptions(baseUrl: "https://your-backend-api.com/api"),
  );
  final DatabaseService _db = DatabaseService.instance;

  // Hàm thực hiện đồng bộ toàn bộ video chưa sync
  Future<void> syncVideos() async {
    final videos = await _db.getVideosNeedSync();

    for (var video in videos) {
      if (video.id == null) continue;

      try {
        // 1. Cập nhật trạng thái đang upload
        await _db.updateVideoStatus(video.id!, SyncStatus.uploading);

        // 2. Chuẩn bị file để upload
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(
            video.filePath,
            filename: video.filePath.split('/').last,
          ),
          "duration": video.duration,
          "createdAt": video.createdAt.toIso8601String(),
        });

        // 3. Gọi API upload
        final response = await _dio.post("/upload", data: formData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 4. Cập nhật trạng thái thành công
          final serverId = response.data['id']?.toString();
          await _db.updateVideoStatus(
            video.id!,
            SyncStatus.synced,
            serverId: serverId,
          );
          print("Sync thành công video: ${video.id}");
        } else {
          await _db.updateVideoStatus(video.id!, SyncStatus.failed);
        }
      } catch (e) {
        print("Lỗi sync video ${video.id}: $e");
        await _db.updateVideoStatus(video.id!, SyncStatus.failed);
      }
    }
  }
}

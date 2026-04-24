import '../../models/video_sync_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();

  DatabaseService._init();

  Future<int> insertVideo(VideoSyncItem item) async {
    return 0;
  }

  Future<List<VideoSyncItem>> getVideosNeedSync() async {
    return [];
  }

  Future<int> updateVideoStatus(
    int id,
    SyncStatus status, {
    String? serverId,
  }) async {
    return 0;
  }

  Future<int> deleteVideo(int id) async {
    return 0;
  }

  Future close() async {}
}

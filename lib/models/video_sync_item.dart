enum SyncStatus {
  local,
  uploading,
  synced,
  failed
}

class VideoSyncItem {
  final int? id;
  final String filePath;
  final int duration; // in seconds
  final DateTime createdAt;
  final SyncStatus syncStatus;
  final String? serverId;

  VideoSyncItem({
    this.id,
    required this.filePath,
    required this.duration,
    required this.createdAt,
    this.syncStatus = SyncStatus.local,
    this.serverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus.name,
      'serverId': serverId,
    };
  }

  factory VideoSyncItem.fromMap(Map<String, dynamic> map) {
    return VideoSyncItem(
      id: map['id'],
      filePath: map['filePath'],
      duration: map['duration'],
      createdAt: DateTime.parse(map['createdAt']),
      syncStatus: SyncStatus.values.byName(map['syncStatus']),
      serverId: map['serverId'],
    );
  }
}

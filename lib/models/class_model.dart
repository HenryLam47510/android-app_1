class ClassModel {
  final String id;
  final String name;
  final String code;
  final String subjectId;
  final String lecturerId;
  final int maxSize;
  final String schedule;
  final int attendanceWindowMinutes;
  final double faceThreshold;
  final List<String> studentIds;
  final List<String> managerIds;
  final double attendanceRate;
  final int totalSessions;
  final List<String> activityLogs;

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    required this.subjectId,
    required this.lecturerId,
    required this.maxSize,
    required this.schedule,
    required this.attendanceWindowMinutes,
    required this.faceThreshold,
    required this.studentIds,
    required this.managerIds,
    required this.attendanceRate,
    required this.totalSessions,
    required this.activityLogs,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      subjectId: json['subject_id'] ?? '',
      lecturerId: json['lecturer_id'] ?? '',
      maxSize: json['max_size'] ?? 0,
      schedule: json['schedule'] ?? '',
      attendanceWindowMinutes: json['attendance_window_minutes'] ?? 10,
      faceThreshold: (json['face_threshold'] is num)
          ? (json['face_threshold'] as num).toDouble()
          : 0.75,
      studentIds: List<String>.from(json['student_ids'] ?? []),
      managerIds: List<String>.from(json['manager_ids'] ?? []),
      attendanceRate: (json['attendance_rate'] is num)
          ? (json['attendance_rate'] as num).toDouble()
          : 0.0,
      totalSessions: json['total_sessions'] ?? 0,
      activityLogs: List<String>.from(json['activity_logs'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'subject_id': subjectId,
      'lecturer_id': lecturerId,
      'max_size': maxSize,
      'schedule': schedule,
      'attendance_window_minutes': attendanceWindowMinutes,
      'face_threshold': faceThreshold,
      'student_ids': studentIds,
      'manager_ids': managerIds,
      'attendance_rate': attendanceRate,
      'total_sessions': totalSessions,
      'activity_logs': activityLogs,
    };
  }
}

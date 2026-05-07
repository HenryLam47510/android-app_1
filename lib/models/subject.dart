class Subject {
  final String id;
  final String code;
  final String name;
  final String description;
  final String lecturerId;
  final List<String> managerIds;
  final List<String> activityLogs;

  Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.lecturerId,
    required this.managerIds,
    required this.activityLogs,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      lecturerId: json['lecturer_id'] ?? '',
      managerIds: List<String>.from(json['manager_ids'] ?? []),
      activityLogs: List<String>.from(json['activity_logs'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'lecturer_id': lecturerId,
      'manager_ids': managerIds,
      'activity_logs': activityLogs,
    };
  }
}

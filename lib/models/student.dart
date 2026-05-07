class Student {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String classId;
  final String status;
  final String? avatarUrl;
  final List<String> faceImageUrls;
  final double attendanceRate;
  final List<String> attendanceHistory;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.classId,
    this.status = 'Đang học',
    this.avatarUrl,
    this.faceImageUrls = const [],
    this.attendanceRate = 0.0,
    this.attendanceHistory = const [],
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    final faceImages = json['face_image_urls'] as List<dynamic>?;
    final history = json['attendance_history'] as List<dynamic>?;
    return Student(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      classId: json['class_id'] ?? '',
      status: json['status'] ?? 'Đang học',
      avatarUrl: json['avatar_url'],
      faceImageUrls: faceImages != null
          ? faceImages.map((item) => item.toString()).toList()
          : [],
      attendanceRate: (json['attendance_rate'] is num)
          ? (json['attendance_rate'] as num).toDouble()
          : 0.0,
      attendanceHistory: history != null
          ? history.map((item) => item.toString()).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'class_id': classId,
      'status': status,
      'avatar_url': avatarUrl,
      'face_image_urls': faceImageUrls,
      'attendance_rate': attendanceRate,
      'attendance_history': attendanceHistory,
    };
  }
}

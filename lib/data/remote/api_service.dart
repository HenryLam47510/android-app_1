import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cross_file/cross_file.dart';
import '../../models/post.dart';
import '../../features/study/study_session.dart';
import '../../models/admin_video.dart';

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
  static String get aiBaseUrl => baseUrl;

  // Hàm gọi AI nhận diện độ tập trung
  static Future<double> predictFocus(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$aiBaseUrl/predict'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        return (json['focus_level'] as num).toDouble();
      }
    } catch (e) {
      print("AI API Error: $e");
    }
    return 0.5; // Trả về mặc định nếu lỗi
  }

  static Future<Map<String, dynamic>> analyzeFrame(
    XFile imageFile, {
    int userId = 1,
    String? timestamp,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$aiBaseUrl/analyze-frame'),
      );
      request.fields['user_id'] = userId.toString();
      request.fields['timestamp'] =
          timestamp ?? DateTime.now().toIso8601String();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: imageFile.name),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return jsonDecode(responseData) as Map<String, dynamic>;
      }
      throw Exception('Analyze frame failed: ${response.statusCode}');
    } catch (e) {
      print('AI analyzeFrame error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/dashboard'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception('Failed to load dashboard');
    } catch (e) {
      print("Dashboard API Error: $e");

      return {
        "totalStudents": 0,
        "totalUsers": 0,
        "totalFrames": 0,
        "totalImages": 0,
        "totalSessions": 0,
        "todayFrames": 0,
        "totalAiAnalyses": 0,
        "attendanceToday": 0,
        "recentActivities": [],
      };
    }
  }

  static String _makeAbsoluteUrl(String value) {
    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }
    return value;
  }

  static Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/users'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) {
        final user = item as Map<String, dynamic>;
        if (user['avatar_url'] is String) {
          user['avatar_url'] = _makeAbsoluteUrl(user['avatar_url'] as String);
        }
        return user;
      }).toList();
    }
    throw Exception('Failed to load admin users');
  }

  static Future<Map<String, dynamic>> createAdminUser({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final user = jsonDecode(response.body) as Map<String, dynamic>;
      if (user['avatar_url'] is String) {
        user['avatar_url'] = _makeAbsoluteUrl(user['avatar_url'] as String);
      }
      return user;
    }
    throw Exception('Failed to create admin user: ${response.body}');
  }

  static Future<Map<String, dynamic>> updateAdminUser({
    required int userId,
    String? name,
    String? email,
    String? password,
    String? role,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (role != null) 'role': role,
      }),
    );
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body) as Map<String, dynamic>;
      if (user['avatar_url'] is String) {
        user['avatar_url'] = _makeAbsoluteUrl(user['avatar_url'] as String);
      }
      return user;
    }
    throw Exception('Failed to update admin user: ${response.body}');
  }

  static Future<bool> deleteAdminUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId'),
    );
    return response.statusCode == 200;
  }

  static Future<bool> uploadAdminUserAvatar({
    required int userId,
    Uint8List? bytes,
    String? filename,
    String? path,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/admin/users/$userId/avatar'),
    );
    if (bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'avatar',
          bytes,
          filename: filename ?? 'avatar.jpg',
        ),
      );
    } else if (path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          path,
          filename: filename ?? path.split('/').last,
        ),
      );
    } else {
      throw Exception('No avatar file provided');
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    }
    final responseData = await response.stream.bytesToString();
    throw Exception('Failed to upload avatar: $responseData');
  }

  static Future<List<Map<String, dynamic>>> getAdminUserDailyStats({
    int? userId,
    DateTime? date,
  }) async {
    final queryParameters = <String, String>{};
    if (userId != null) {
      queryParameters['user_id'] = userId.toString();
    }
    if (date != null) {
      queryParameters['date'] = date.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse('$baseUrl/admin/user-daily-stats').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load admin user daily stats');
  }

  static Future<List<AdminVideo>> getAdminVideos() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/videos'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => AdminVideo.fromJson(item)).toList();
    }
    throw Exception('Failed to load admin videos');
  }

  static Future<List<Map<String, dynamic>>> getEmotionTimeline(
    int userId, {
    DateTime? date,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/emotion-timeline/$userId').replace(
      queryParameters: date != null
          ? {'date': date.toIso8601String().split('T')[0]}
          : null,
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) {
        final frame = item as Map<String, dynamic>;
        if (frame['image_url'] is String) {
          frame['image_url'] = _makeAbsoluteUrl(frame['image_url'] as String);
        }
        return frame;
      }).toList();
    }
    throw Exception('Failed to load emotion timeline');
  }

  static String getFrameImageUrl(int frameId) {
    return _makeAbsoluteUrl('/frame-emotion/$frameId/image');
  }

  /// Lấy lịch sử học tập từ backend
  static Future<List<StudySession>> getStudyHistory({int? userId}) async {
    final uri = Uri.parse('$baseUrl/study/history').replace(
      queryParameters: userId != null ? {'user_id': userId.toString()} : null,
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => StudySession.fromJson(item)).toList();
    }
    throw Exception('Failed to load study history');
  }

  static Future<bool> saveStudySession(StudySession session) async {
    final response = await http.post(
      Uri.parse('$baseUrl/study'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(session.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> deleteVideo(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/videos/$id'));
    return response.statusCode == 200;
  }

  static Future<bool> deleteSegment(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/segments/$id'),
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: ${response.body}');
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Register failed: ${response.body}');
  }

  static Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse("https://jsonplaceholder.typicode.com/posts"),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }
}

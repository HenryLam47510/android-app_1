import 'dart:convert';
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
        "activeStudents": 0,
        "attendanceToday": 0,
        "totalEvents": 0,
        "focusAlerts": 0,
        "averageFocusScore": 0,
        "recentEvents": [],
      };
    }
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
      return body.map((item) => item as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load emotion timeline');
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

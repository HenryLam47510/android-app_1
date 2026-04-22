import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/post.dart';
import '../../features/study/study_session.dart';
import '../../models/admin_video.dart';

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
  static String get aiBaseUrl => baseUrl;

  // Hàm gọi AI nhận diện độ tập trung
  static Future<double> predictFocus(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$aiBaseUrl/predict'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return (json['focus_level'] as num).toDouble();
      }
    } catch (e) {
      print("AI API Error: $e");
    }
    return 0.5; // Trả về mặc định nếu lỗi
  }

  static Future<Map<String, dynamic>> getAdminDashboardStats() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      "totalVideos": 150,
      "totalStorage": "12.5 GB",
      "totalAiAnalyses": 1240,
    };
  }

  static Future<List<AdminVideo>> getAdminVideos() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/videos'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => AdminVideo.fromJson(item)).toList();
    }
    throw Exception('Failed to load admin videos');
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
    return true;
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

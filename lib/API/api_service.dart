import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/study_session.dart';
import '../models/admin_video.dart';

class ApiService {
  static const String baseUrl = "https://your-backend-api.com/api";

  // --- EXISTING METHODS ---

  static Future<String> detectEmotion(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect-emotion'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['emotion']; 
      }
      return "Error";
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<bool> uploadSessionMedia(String filePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload-session'));
      request.files.add(await http.MultipartFile.fromPath('video', filePath));
      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Upload error: $e");
      return false;
    }
  }

  static Future<bool> saveStudySession(StudySession session) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'startTime': session.startTime.toIso8601String(),
          'duration': session.duration,
          'happy': session.happy,
          'neutral': session.neutral,
          'sad': session.sad,
          'tired': session.tired,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<StudySession>> getStudyHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sessions'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => StudySession(
          startTime: DateTime.parse(item['startTime']),
          duration: item['duration'],
          happy: item['happy'].toDouble(),
          neutral: item['neutral'].toDouble(),
          sad: item['sad'].toDouble(),
          tired: item['tired'].toDouble(),
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // --- ADMIN METHODS (MOCK DATA) ---

  static Future<List<AdminVideo>> getAdminVideos() async {
    // Giả lập lấy danh sách video cho Admin
    await Future.delayed(const Duration(seconds: 1));
    return [
      AdminVideo(
        id: "v1",
        filename: "session_20241024_0830.mp4",
        duration: const Duration(minutes: 45),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: "processed",
        videoUrl: "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        segments: [
          VideoSegment(id: "s1", segmentNumber: 1, startTime: Duration.zero, endTime: const Duration(minutes: 10), status: "completed"),
          VideoSegment(id: "s2", segmentNumber: 2, startTime: const Duration(minutes: 10), endTime: const Duration(minutes: 20), status: "completed"),
        ],
        aiResults: [
          AiResult(timestamp: "00:05", emotion: "Hứng thú"),
          AiResult(timestamp: "00:15", emotion: "Tập trung"),
          AiResult(timestamp: "00:30", emotion: "Mệt mỏi"),
        ],
      ),
      AdminVideo(
        id: "v2",
        filename: "session_20241023_1400.mp4",
        duration: const Duration(minutes: 30),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: "raw",
        videoUrl: "",
        segments: [],
        aiResults: [],
      ),
    ];
  }

  static Future<bool> deleteVideo(String videoId) async {
    // Giả lập xóa video
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<bool> deleteSegment(String segmentId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  static Future<Map<String, dynamic>> getAdminDashboardStats() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      "totalVideos": 150,
      "totalStorage": "12.5 GB",
      "totalAiAnalyses": 1240,
    };
  }

  static Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Post.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load posts");
    }
  }
}

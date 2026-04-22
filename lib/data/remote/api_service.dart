import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/post.dart';
import '../../features/study/study_session.dart';
import '../../models/admin_video.dart';

class ApiService {
  // Thay đổi IP này thành IP máy tính của bạn khi chạy Backend
  static const String aiBaseUrl =
      "http://10.0.2.2:8000"; // 10.0.2.2 là localhost cho Android Emulator
  static const String baseUrl = "https://your-backend-api.com/api";

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
    return []; // Mock data
  }

  /// Lấy lịch sử học tập (mock data cho demo)
  static Future<List<StudySession>> getStudyHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    return [
      StudySession(
        id: '1',
        startTime: now.subtract(const Duration(days: 2)),
        duration: 45,
        avgFocusScore: 0.85,
        dominantEmotion: 'natural',
        emotionFrequency: {'natural': 35, 'happy': 8, 'surprised': 2},
        totalFrames: 45,
      ),
      StudySession(
        id: '2',
        startTime: now.subtract(const Duration(days: 1)),
        duration: 60,
        avgFocusScore: 0.72,
        dominantEmotion: 'natural',
        emotionFrequency: {'natural': 40, 'happy': 12, 'sad': 8},
        totalFrames: 60,
      ),
      StudySession(
        id: '3',
        startTime: now,
        duration: 30,
        avgFocusScore: 0.58,
        dominantEmotion: 'happy',
        emotionFrequency: {'happy': 15, 'natural': 12, 'surprised': 3},
        totalFrames: 30,
      ),
    ];
  }

  static Future<bool> saveStudySession(StudySession session) async {
    return true;
  }

  static Future<bool> deleteVideo(String id) async {
    return true;
  }

  static Future<bool> deleteSegment(String id) async {
    return true;
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

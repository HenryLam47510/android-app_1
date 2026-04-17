import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/study_session.dart';

class ApiService {
  // Đổi thành URL server thật của bạn khi có
  static const String baseUrl = "https://your-backend-api.com/api";

  // 1. Emotion Detection API (Gửi ảnh/frame để nhận diện cảm xúc)
  static Future<String> detectEmotion(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect-emotion'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var json = jsonDecode(responseData);
        return json['emotion']; // Trả về chuỗi cảm xúc (ví dụ: "Happy", "Focus")
      }
      return "Error";
    } catch (e) {
      return "Error: $e";
    }
  }

  // 2. Upload Video / Session API
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

  // 3. Save Study Session API (Lưu thông tin buổi học vào DB)
  static Future<bool> saveStudySession(StudySession session) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': session.id,
          'date': session.date.toIso8601String(),
          'duration': session.duration.inSeconds,
          'avgFocusScore': session.avgFocusScore,
          'dominantEmotion': session.dominantEmotion,
          'videoPath': session.videoPath,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 4. Get Study History API (Lấy danh sách lịch sử)
  static Future<List<StudySession>> getStudyHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sessions'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => StudySession(
          id: item['id'],
          date: DateTime.parse(item['date']),
          duration: Duration(seconds: item['duration']),
          avgFocusScore: item['avgFocusScore'].toDouble(),
          dominantEmotion: item['dominantEmotion'],
          videoPath: item['videoPath'],
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 5. Get Session Detail API (Lấy chi tiết 1 buổi học)
  static Future<StudySession?> getSessionDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sessions/$id'));
      if (response.statusCode == 200) {
        var item = jsonDecode(response.body);
        return StudySession(
          id: item['id'],
          date: DateTime.parse(item['date']),
          duration: Duration(seconds: item['duration']),
          avgFocusScore: item['avgFocusScore'].toDouble(),
          dominantEmotion: item['dominantEmotion'],
          videoPath: item['videoPath'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // API Test mẫu cũ (vẫn giữ để bạn tham khảo)
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

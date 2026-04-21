import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trung tâm trợ giúp"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hướng dẫn sử dụng",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStep(1, "Mở tab Monitor trên thanh điều hướng."),
            _buildStep(2, "Nhấn nút 'Bắt đầu học ngay' để kích hoạt camera."),
            _buildStep(3, "App sẽ tự động ghi lại và phân tích biểu cảm của bạn."),
            _buildStep(4, "Nhấn 'Kết thúc buổi học' khi bạn hoàn thành."),
            _buildStep(5, "Xem lại kết quả chi tiết trong tab Lịch sử (History)."),
            
            const SizedBox(height: 32),
            const Text(
              "Câu hỏi thường gặp (FAQ)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFAQ(
              "Q: App nhận diện cảm xúc như thế nào?",
              "A: Hệ thống sử dụng mô hình trí tuệ nhân tạo (AI) để phân tích các điểm đặc trưng trên khuôn mặt qua camera theo thời gian thực."
            ),
            _buildFAQ(
              "Q: Dữ liệu video có được bảo mật không?",
              "A: Mọi dữ liệu hình ảnh được xử lý trực tiếp trên thiết bị hoặc mã hóa khi gửi lên server để đảm bảo quyền riêng tư của bạn."
            ),
            _buildFAQ(
              "Q: Làm sao để tăng độ chính xác của AI?",
              "A: Bạn nên ngồi học ở nơi có đủ ánh sáng và đặt điện thoại ở vị trí nhìn rõ khuôn mặt."
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(
              number.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}

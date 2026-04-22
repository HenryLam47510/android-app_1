import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trình quản lý đa phương tiện'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2, // Chia làm 2 cột
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildCameraButton(),
            _buildGalleryButton(),
            _buildVideoButton(),
            _buildHistoryButton(),
          ],
        ),
      ),
    );
  }

  // 1. Widget Mở Camera
  Widget _buildCameraButton() {
    return _BaseMenuButton(
      label: "Mở Camera",
      icon: Icons.camera_alt_rounded,
      color: Colors.redAccent,
      onTap: () => print("Đang kích hoạt Camera..."),
    );
  }

  // 2. Widget Tải ảnh từ thư viện
  Widget _buildGalleryButton() {
    return _BaseMenuButton(
      label: "Thư viện ảnh",
      icon: Icons.photo_library_rounded,
      color: Colors.blueAccent,
      onTap: () => print("Đang mở thư viện ảnh..."),
    );
  }

  // 3. Widget Mở Video
  Widget _buildVideoButton() {
    return _BaseMenuButton(
      label: "Xem Video",
      icon: Icons.play_circle_fill_rounded,
      color: Colors.orangeAccent,
      onTap: () => print("Đang mở danh sách Video..."),
    );
  }

  // 4. Widget Mở Lịch sử
  Widget _buildHistoryButton() {
    return _BaseMenuButton(
      label: "Lịch sử",
      icon: Icons.history_rounded,
      color: Colors.greenAccent,
      onTap: () => print("Đang xem lịch sử hoạt động..."),
    );
  }
}

// Widget dùng chung để tạo kiểu dáng cho các nút (giúp code ngắn gọn hơn)
class _BaseMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BaseMenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';
import '../../constants/app_state.dart';
import '../home/auth_screen.dart'; // Import để chuyển hướng khi đăng xuất
import 'admin_video_list_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getAdminDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tổng quan hệ thống",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      "Tổng Video",
                      stats['totalVideos']?.toString() ?? "0",
                      Icons.video_library,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      "Dung lượng",
                      stats['totalStorage'] ?? "0 GB",
                      Icons.storage,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      "Phân tích AI",
                      stats['totalAiAnalyses']?.toString() ?? "0",
                      Icons.auto_awesome,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      "Người dùng",
                      "45",
                      Icons.people,
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Text(
                  "Quản lý hệ thống",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                _buildMenuTile(
                  context,
                  "Quản lý Video & Segment",
                  "Xem danh sách, chi tiết và dọn dẹp dữ liệu",
                  Icons.video_settings,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminVideoListPage(),
                    ),
                  ),
                ),

                _buildMenuTile(
                  context,
                  "Cấu hình & Cài đặt",
                  "Chỉnh sửa tham số AI và đổi giao diện",
                  Icons.settings_suggest,
                  () {
                    _showSettingsDialog(context);
                  },
                ),
                const SizedBox(height: 24),
                _buildMenuTile(
                  context,
                  "Đăng xuất",
                  "Thoát khỏi tài khoản Giáo viên",
                  Icons.logout_rounded,
                  () => _showLogoutDialog(context),
                  color: Colors.redAccent,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận đăng xuất"),
        content: const Text(
          "Thầy/Cô có chắc chắn muốn thoát khỏi hệ thống quản trị không?",
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              // Cập nhật trạng thái
              isLoggedInNotifier.value = false;
              // Xóa toàn bộ stack và quay về màn hình đăng nhập
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cài đặt hệ thống"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Chế độ giao diện"),
            const SizedBox(height: 10),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => themeNotifier.value = ThemeMode.light,
                      icon: const Icon(Icons.light_mode),
                      label: const Text("Sáng"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentMode == ThemeMode.light
                            ? Colors.blue.withOpacity(0.2)
                            : null,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => themeNotifier.value = ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: const Text("Tối"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentMode == ThemeMode.dark
                            ? Colors.blue.withOpacity(0.2)
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    String sub,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.indigo, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../constants/app_state.dart';
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Đăng xuất"),
                  content: const Text("Bạn có chắc chắn muốn thoát quyền Admin?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Hủy"),
                    ),
                    TextButton(
                      onPressed: () {
                        // Cập nhật trạng thái đăng xuất
                        isLoggedInNotifier.value = false;
                        // Quay về màn hình gốc (AuthScreen sẽ tự hiển thị do isLoggedInNotifier thay đổi)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
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
                    _buildStatCard("Tổng Video", stats['totalVideos']?.toString() ?? "0", Icons.video_library, Colors.blue),
                    _buildStatCard("Dung lượng", stats['totalStorage'] ?? "0 GB", Icons.storage, Colors.orange),
                    _buildStatCard("Phân tích AI", stats['totalAiAnalyses']?.toString() ?? "0", Icons.auto_awesome, Colors.purple),
                    _buildStatCard("Người dùng", "45", Icons.people, Colors.green),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text("Quản lý hệ thống", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                _buildMenuTile(
                  context,
                  "Quản lý Video & Segment",
                  "Xem danh sách, chi tiết và dọn dẹp dữ liệu",
                  Icons.video_settings,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminVideoListPage())),
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
              ],
            ),
          );
        },
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
                        backgroundColor: currentMode == ThemeMode.light ? Colors.blue.withOpacity(0.2) : null,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => themeNotifier.value = ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: const Text("Tối"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentMode == ThemeMode.dark ? Colors.blue.withOpacity(0.2) : null,
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, String sub, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

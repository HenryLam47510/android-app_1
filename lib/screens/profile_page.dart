import 'package:flutter/material.dart';
import '../constants/app_state.dart';
import 'api_test_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cài đặt hệ thống"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.language),
              title: Text("Ngôn ngữ"),
              trailing: Text("Tiếng Việt"),
            ),
            ListTile(
              leading: Icon(Icons.cloud_upload),
              title: Text("Đồng bộ dữ liệu"),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: _showSettingsDialog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text("Nguyễn Văn A", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("Học sinh lớp 12A1 • ID: 2024001", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildProfileStat("12", "Buổi học"),
                  _buildProfileStat("45h", "Tổng giờ"),
                  _buildProfileStat("8.5", "Focus"),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text("Thử nghiệm API", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.orangeAccent),
              ),
              child: ListTile(
                leading: const Icon(Icons.api, color: Colors.orange),
                title: const Text("Xem danh sách từ API"),
                subtitle: const Text("JSONPlaceholder Demo"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ApiTestPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            const Text("Cài đặt nhanh", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, _) {
                      return SwitchListTile(
                        title: const Text("Chế độ tối (Dark Mode)"),
                        secondary: const Icon(Icons.dark_mode_outlined),
                        value: currentMode == ThemeMode.dark,
                        onChanged: (val) => themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Thông báo đẩy"),
                    secondary: const Icon(Icons.notifications_active_outlined),
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text("Tài khoản", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildProfileOption(Icons.edit_outlined, "Chỉnh sửa thông tin"),
            _buildProfileOption(Icons.security_outlined, "Bảo mật & Mật khẩu"),
            _buildProfileOption(Icons.help_outline, "Hướng dẫn sử dụng"),
            _buildProfileOption(Icons.logout, "Đăng xuất", color: Colors.red, onTap: () => isLoggedInNotifier.value = false),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

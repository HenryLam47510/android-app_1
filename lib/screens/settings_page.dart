import 'package:flutter/material.dart';
import '../constants/app_state.dart';
import 'change_password_page.dart';
import 'help_center_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Trạng thái cho các tính năng mới
  bool _enableNotifications = true;
  bool _studyReminders = true;
  bool _biometricLogin = false;
  bool _autoStartCamera = false;

  void _showDeleteHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa lịch sử học tập?"),
        content: const Text(
          "Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa toàn bộ dữ liệu buổi học không?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Xóa sạch", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt"),
        backgroundColor: Colors.lightBlue, // Màu xanh
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // --- NOTIFICATIONS ---
          _buildSectionHeader("Thông báo", Icons.notifications_none),
          SwitchListTile(
            title: const Text("Bật thông báo"),
            value: _enableNotifications,
            onChanged: (val) => setState(() => _enableNotifications = val),
          ),
          SwitchListTile(
            title: const Text("Nhắc nhở học tập"),
            value: _studyReminders,
            onChanged: _enableNotifications
                ? (val) => setState(() => _studyReminders = val)
                : null,
          ),

          const Divider(),

          // --- SECURITY ---
          _buildSectionHeader("Bảo mật", Icons.security),
          ListTile(
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
            ),
          ),
          SwitchListTile(
            title: const Text("Đăng nhập sinh trắc học"),
            subtitle: const Text("Sử dụng vân tay hoặc khuôn mặt"),
            value: _biometricLogin,
            onChanged: (val) => setState(() => _biometricLogin = val),
          ),
          ListTile(
            title: const Text("Lịch sử đăng nhập"),
            trailing: const Icon(Icons.history),
            onTap: () {},
          ),

          const Divider(),

          // --- DATA MANAGEMENT ---
          _buildSectionHeader("Quản lý dữ liệu", Icons.storage),
          ListTile(
            title: const Text("Xuất báo cáo học tập"),
            subtitle: const Text("Định dạng PDF / Excel"),
            leading: const Icon(Icons.ios_share),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Sao lưu dữ liệu"),
            leading: const Icon(Icons.cloud_upload_outlined),
            onTap: () {},
          ),
          ListTile(
            title: const Text(
              "Xóa sạch lịch sử học tập",
              style: TextStyle(color: Colors.red),
            ),
            leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            onTap: _showDeleteHistoryDialog,
          ),

          const Divider(),

          // --- HELP CENTER ---
          _buildSectionHeader("Hỗ trợ người dùng", Icons.help_outline),
          ListTile(
            title: const Text("Hướng dẫn sử dụng"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterPage()),
            ),
          ),
          ListTile(
            title: const Text("Câu hỏi thường gặp (FAQ)"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterPage()),
            ),
          ),
          ListTile(
            title: const Text("Liên hệ hỗ trợ"),
            trailing: const Text(
              "support@study.ai",
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
            onTap: () {},
          ),

          const Divider(),

          // --- ABOUT APP ---
          _buildSectionHeader("Thông tin ứng dụng", Icons.info_outline),
          const ListTile(
            title: Text("Phiên bản"),
            trailing: Text("1.0.2 (Build 202410)"),
          ),
          ListTile(title: const Text("Thông tin nhà phát triển"), onTap: () {}),
          ListTile(
            title: const Text("Chính sách quyền riêng tư"),
            onTap: () {},
          ),
          ListTile(title: const Text("Điều khoản dịch vụ"), onTap: () {}),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

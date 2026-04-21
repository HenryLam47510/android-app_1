import 'package:flutter/material.dart';
import '../constants/app_state.dart';
import '../models/user.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'help_center_page.dart';
import 'settings_page.dart';
import 'admin_dashboard_page.dart'; // Import trang Admin

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<User>(
      valueListenable: currentUserNotifier,
      builder: (context, user, _) {
        // Giả sử admin@gmail.com là tài khoản Admin
        bool isAdmin = user.email == "admin@gmail.com";

        return Scaffold(
          appBar: AppBar(
            title: const Text("Cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: User Info
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.avatar),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          if (isAdmin)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.verified, color: Colors.blue, size: 20),
                            ),
                        ],
                      ),
                      Text(user.email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfilePage()),
                          );
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Chỉnh sửa Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- ADMIN PANEL (Chỉ hiện cho Admin) ---
                if (isAdmin) ...[
                  const Text("Quản trị viên", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.indigo.withOpacity(0.05),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.indigo, width: 0.5),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.indigo),
                      title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      subtitle: const Text("Quản lý video, segment và kết quả AI"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.indigo),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Section: Thống kê học tập (Study Statistics)
                const Text("Thống kê học tập", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard("Tổng thời gian", "12h", Icons.timer_outlined, Colors.orange),
                    _buildStatCard("Số buổi học", "15", Icons.history_edu, Colors.blue),
                    _buildStatCard("Cảm xúc chính", "Bình thường", Icons.face_outlined, Colors.green),
                    _buildStatCard("Độ tập trung", "72%", Icons.psychology_outlined, Colors.purple),
                  ],
                ),
                
                const SizedBox(height: 32),

                // Section: Tài khoản & Hệ thống
                const Text("Tài khoản & Hệ thống", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildOptionTile(
                  Icons.settings, 
                  "Cài đặt ứng dụng",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                ),
                _buildOptionTile(
                  Icons.security, 
                  "Bảo mật & Mật khẩu",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                    );
                  },
                ),
                _buildOptionTile(
                  Icons.help_center, 
                  "Trung tâm trợ giúp",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpCenterPage()),
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                const Text("Thành tích (Huy hiệu)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildBadge(Icons.timer, "Chăm chỉ", Colors.orange),
                      _buildBadge(Icons.auto_awesome, "Tập trung", Colors.indigo),
                      _buildBadge(Icons.military_tech, "Bền bỉ", Colors.green),
                      _buildBadge(Icons.emoji_events, "Vô địch", Colors.amber),
                      _buildBadge(Icons.local_fire_department, "Nhiệt huyết", Colors.red),
                    ],
                  ),
                ),

                const Divider(height: 48),
                _buildOptionTile(
                  Icons.logout, 
                  "Đăng xuất", 
                  color: Colors.red, 
                  onTap: () => isLoggedInNotifier.value = false,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, {Color color = Colors.black87, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap ?? () {},
    );
  }
}

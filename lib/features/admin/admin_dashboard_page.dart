import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';
import '../../constants/app_state.dart';
import '../home/auth_screen.dart'; // Import để chuyển hướng khi đăng xuất
import 'admin_video_list_page.dart';
import 'student_management_page.dart';
import 'class_management_page.dart';

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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tổng quan hệ thống",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      context,
                      "Tổng Sinh viên",
                      stats['totalStudents']?.toString() ?? "0",
                      Icons.school,
                      Colors.teal,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StudentManagementPage(),
                        ),
                      ),
                      helper: 'Quản lý hồ sơ sinh viên, QR code, Import Excel',
                    ),
                    _buildStatCard(
                      context,
                      "Số lớp",
                      stats['totalClasses']?.toString() ?? "0",
                      Icons.class_,
                      Colors.indigo,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ClassManagementPage(),
                        ),
                      ),
                      helper: 'Xem lớp, môn học, lịch học và quản lý buổi học',
                    ),
                    _buildStatCard(
                      context,
                      "Điểm danh hôm nay",
                      stats['attendanceToday']?.toString() ?? "0",
                      Icons.check_circle,
                      Colors.green,
                      onTap: () => _showAttendanceSummary(context),
                      helper: 'Kiểm tra tình hình điểm danh hiện tại',
                    ),
                    _buildStatCard(
                      context,
                      "Camera online",
                      stats['camerasOnline']?.toString() ?? "0",
                      Icons.videocam,
                      Colors.deepOrange,
                      onTap: () => _showCameraStatus(context),
                      helper: 'Kiểm tra trạng thái camera và FPS',
                    ),
                    _buildStatCard(
                      context,
                      "Tổng Video",
                      stats['totalVideos']?.toString() ?? "0",
                      Icons.video_library,
                      Colors.blue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminVideoListPage(),
                        ),
                      ),
                      helper: 'Danh sách video upload/quét và segment',
                    ),
                    _buildStatCard(
                      context,
                      "Phân tích AI",
                      stats['totalAiAnalyses']?.toString() ?? "0",
                      Icons.auto_awesome,
                      Colors.purple,
                      onTap: () => _showAiDetail(context),
                      helper: 'Xem tỷ lệ nhận diện AI và cấu hình ngưỡng',
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'Biểu đồ chuyên cần',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chuyên cần theo lớp trong 7 ngày',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildAttendanceMarker(0.8, 'AI01'),
                            _buildAttendanceMarker(0.7, 'WEB02'),
                            _buildAttendanceMarker(0.95, 'DS03'),
                            _buildAttendanceMarker(0.65, 'ML04'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Hoạt động gần đây',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...((stats['recentActivities'] as List<dynamic>?) ?? [])
                    .map(
                      (activity) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.fiber_manual_record,
                              size: 10,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(activity.toString())),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                const SizedBox(height: 14),
                const Text(
                  "Quản lý hệ thống",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

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
                  "Quản lý Sinh viên",
                  "Thêm, sửa, xóa sinh viên và tải lên ảnh chân dung",
                  Icons.school,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentManagementPage(),
                    ),
                  ),
                ),

                _buildMenuTile(
                  context,
                  "Quản lý Lớp học & Môn học",
                  "Chia lớp, gán môn học và giảng viên",
                  Icons.class_,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClassManagementPage(),
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

  void _showAiDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phân tích AI'),
        content: const Text('''Đã thực hiện 1240 lần phân tích.
- Điểm trung bình mô hình: 87%
- Các buổi phân tích gần đây: 8
- Cấu hình ngưỡng nhận diện khuôn mặt: 75%'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dung lượng'),
        content: const Text('''Dung lượng hiện tại: 12.5 GB
- Video gốc: 8.2 GB
- Dữ liệu AI: 2.1 GB
- Cache: 2.2 GB

Bạn có thể dọn dẹp cache khi cần giải phóng bộ nhớ.'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showAttendanceSummary(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điểm danh hôm nay'),
        content: const Text('''324 sinh viên đã điểm danh hôm nay.
- Tỉ lệ điểm danh trung bình: 82%.
- Lớp có chuyên cần cao nhất: AI01.
- Lớp cần chú ý: ML04.'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showCameraStatus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera online'),
        content: const Text('''12 camera đang online.
- Camera chính: online, 30 FPS.
- Camera phụ C3: online, 24 FPS.
- Camera ngoại tuyến: C7.'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMarker(double ratio, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: ratio,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cài đặt hệ thống"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Giao diện"),
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
              const Divider(height: 32),
              const Text("AI & Camera"),
              const SizedBox(height: 10),
              const Text('Độ chính xác nhận diện: 75%'),
              const Text('FPS xử lý camera: 25'),
              const Text('Camera mặc định: Front'),
              const SizedBox(height: 12),
              const Text('Ngưỡng nhận diện khuôn mặt: 0.75'),
              const Text('Auto retry khi detect fail: bật'),
              const Divider(height: 32),
              const Text("Hệ thống"),
              const SizedBox(height: 10),
              const Text('Ngôn ngữ: Tiếng Việt'),
              const Text('Backup dữ liệu: chưa kích hoạt'),
              const Text('Giới hạn dung lượng video: 50 GB'),
            ],
          ),
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
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
    String? helper,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios, size: 12, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
            if (helper != null) ...[
              const SizedBox(height: 4),
              Text(
                helper,
                style: const TextStyle(fontSize: 9, color: Colors.black45),
              ),
            ],
          ],
        ),
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
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.indigo, size: 24),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onTap,
      ),
    );
  }
}

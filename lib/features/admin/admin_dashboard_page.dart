import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';
import '../../constants/app_state.dart';
import '../home/auth_screen.dart'; // Import để chuyển hướng khi đăng xuất
import 'admin_emotion_timeline_page.dart';
import 'admin_latest_ai_analysis_page.dart';
import 'admin_monitor_reports_page.dart';
import 'admin_student_accounts_page.dart';
import 'admin_user_daily_stats_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getAdminDashboardStats();
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = ApiService.getAdminDashboardStats();
    });
    await _statsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Làm mới",
            onPressed: _refreshStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Đăng xuất",
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
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
                      "Số học sinh",
                      stats['totalStudents']?.toString() ?? "0",
                      Icons.school,
                      Colors.teal,
                      onTap: () async {
                        final changed = await Navigator.push<bool?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminStudentAccountsPage(),
                          ),
                        );
                        if (changed == true) {
                          await _refreshStats();
                        }
                      },
                      helper:
                          'Mở danh sách học sinh để thêm, sửa, xóa và quản lý thông tin',
                    ),
                    _buildStatCard(
                      context,
                      "Tổng tài khoản",
                      stats['totalUsers']?.toString() ?? "0",
                      Icons.account_box,
                      Colors.indigo,
                      onTap: () async {
                        final changed = await Navigator.push<bool?>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminStudentAccountsPage(),
                          ),
                        );
                        if (changed == true) {
                          await _refreshStats();
                        }
                      },
                      helper:
                          'Hiển thị toàn bộ tài khoản người dùng trong hệ thống',
                    ),
                    _buildStatCard(
                      context,
                      "Khung hình hôm nay",
                      stats['todayFrames']?.toString() ?? "0",
                      Icons.photo_camera,
                      Colors.green,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminEmotionTimelinePage(),
                        ),
                      ),
                      helper:
                          'Xem toàn bộ khung hình đã phân tích trong ngày hôm nay',
                    ),
                    _buildStatCard(
                      context,
                      "Snapshot đã lưu",
                      stats['totalImages']?.toString() ?? "0",
                      Icons.photo_library,
                      Colors.deepOrange,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminEmotionTimelinePage(),
                        ),
                      ),
                      helper:
                          'Xem lại các snapshot ảnh đã lưu từ quá trình phân tích AI',
                    ),
                    _buildStatCard(
                      context,
                      "Timeline Cảm Xúc",
                      stats['totalFrames']?.toString() ?? "0",
                      Icons.timeline,
                      Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminEmotionTimelinePage(),
                        ),
                      ),
                      helper:
                          'Xem toàn bộ lịch sử cảm xúc và các snapshot đã thu thập',
                    ),
                    _buildStatCard(
                      context,
                      "Lượt AI phân tích",
                      stats['totalAiAnalyses']?.toString() ?? "0",
                      Icons.auto_awesome,
                      Colors.purple,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLatestAiAnalysisPage(),
                        ),
                      ),
                      helper:
                          'Xem ảnh phóng to của học sinh và dữ liệu từng snapshot AI',
                    ),
                    _buildStatCard(
                      context,
                      "Báo cáo rời camera",
                      stats['totalAwayReports']?.toString() ?? "0",
                      Icons.report,
                      Colors.redAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminMonitorReportsPage(),
                        ),
                      ),
                      helper:
                          'Xem lịch sử rời màn hình camera và thời gian away',
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
                ...((stats['recentActivities'] as List<dynamic>?) ?? []).map(
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
                ),
                const SizedBox(height: 14),
                const Text(
                  "Quản lý hệ thống",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildMenuTile(
                  context,
                  "Quản lý Timeline & Snapshots",
                  "Xem timeline cảm xúc, snapshots và quản lý dữ liệu",
                  Icons.timeline,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminEmotionTimelinePage(),
                    ),
                  ),
                ),

                _buildMenuTile(
                  context,
                  "Thống kê ảnh theo user/ngày",
                  "Xem số lượng khung hình và ảnh đã lưu theo từng tài khoản",
                  Icons.grid_view,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminUserDailyStatsPage(),
                    ),
                  ),
                ),

                _buildMenuTile(
                  context,
                  "Báo cáo rời camera",
                  "Xem lịch sử rời màn hình camera và thời gian away",
                  Icons.report,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminMonitorReportsPage(),
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

  void _showAiDetail(BuildContext context, int totalAiAnalyses) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phân tích AI'),
        content: Text('''Tổng lượt phân tích AI: $totalAiAnalyses lượt.
- Hiệu suất mô hình: 75%-90%.
- Dữ liệu này phản ánh số khung hình đã xử lý.
- Chuyển sang Timeline để xem kết quả chi tiết.'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTodayFrameSummary(
    BuildContext context,
    int todayFrames,
    int attendanceToday,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khung hình hôm nay'),
        content: Text('''Số khung hình đã phân tích hôm nay: $todayFrames.
- Số tác vụ ghi nhận chuyên cần hôm nay: $attendanceToday.
- Dữ liệu này phản ánh số lần chụp và phân tích cảm xúc trong ngày.'''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSavedImageSummary(
    BuildContext context,
    int totalImages,
    int totalFrames,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snapshot đã lưu'),
        content: Text('''Số ảnh snapshot đã lưu: $totalImages.
- Tổng khung hình phân tích: $totalFrames.
- Những ảnh này có thể xem lại qua Timeline hoặc chức năng quản lý ảnh.'''),
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

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    _cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Student Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

// Model cho lịch sử học tập
class StudySession {
  final String id;
  final DateTime date;
  final Duration duration;
  final double avgFocusScore;
  final String dominantEmotion;
  final String videoPath;

  StudySession({
    required this.id,
    required this.date,
    required this.duration,
    required this.avgFocusScore,
    required this.dominantEmotion,
    required this.videoPath,
  });
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isMonitoring = false;
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleMonitoring() async {
    if (_isMonitoring) {
      // Dừng monitoring
      await _controller?.stopVideoRecording();
      await _controller?.dispose();
      _controller = null;
      setState(() {
        _isMonitoring = false;
      });
    } else {
      // Bắt đầu monitoring
      if (_cameras.isEmpty) return;
      
      _controller = CameraController(
        _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        ),
        ResolutionPreset.medium,
      );

      try {
        await _controller!.initialize();
        setState(() {
          _isMonitoring = true;
        });
      } catch (e) {
        print("Camera error: $e");
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MonitorPage(isMonitoring: _isMonitoring, controller: _controller),
      const HistoryPage(),
      const PlaceholderPage(title: "Thông báo"),
      const PlaceholderPage(title: "Cá nhân"),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 
        ? FloatingActionButton.large(
            onPressed: _toggleMonitoring,
            backgroundColor: _isMonitoring ? Colors.redAccent : Colors.indigo,
            shape: const CircleBorder(),
            child: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow, color: Colors.white, size: 40),
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                _selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined,
                color: _selectedIndex == 0 ? Colors.indigo : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(
                _selectedIndex == 1 ? Icons.history : Icons.history_outlined,
                color: _selectedIndex == 1 ? Colors.indigo : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(
                _selectedIndex == 2 ? Icons.notifications : Icons.notifications_none,
                color: _selectedIndex == 2 ? Colors.indigo : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            IconButton(
              icon: Icon(
                _selectedIndex == 3 ? Icons.person : Icons.person_outline,
                color: _selectedIndex == 3 ? Colors.indigo : Colors.grey,
              ),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TRANG GIÁM SÁT (HOME) ---
class MonitorPage extends StatelessWidget {
  final bool isMonitoring;
  final CameraController? controller;
  const MonitorPage({super.key, required this.isMonitoring, this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Study Monitor", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(16),
              clipBehavior: Clip.antiAlias, // Di chuyển từ BoxDecoration ra ngoài Container
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isMonitoring && controller != null && controller!.value.isInitialized)
                    CameraPreview(controller!)
                  else
                    const Icon(Icons.camera_front, size: 80, color: Colors.white24),
                  
                  if (isMonitoring)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildLiveBadge(),
                    ),
                  Positioned(
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isMonitoring ? "Đang theo dõi..." : "Sẵn sàng bắt đầu buổi học",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildStatusCard(isMonitoring),
                  const SizedBox(height: 20),
                  _buildFocusIndicator(isMonitoring),
                  const SizedBox(height: 24),
                  _buildAISuggestion(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text("REC", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool monitoring) {
    return Card(
      elevation: 0,
      color: Colors.indigo.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.indigo.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.face_retouching_natural, size: 32, color: Colors.indigo),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Cảm xúc", style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(monitoring ? "Đang tập trung" : "---", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            if (monitoring) const Text("🔥 Cực tốt", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusIndicator(bool monitoring) {
    double score = 0.85;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Độ tập trung", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${(score * 100).toInt()}%", style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: monitoring ? score : 0,
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
          color: Colors.indigo,
          backgroundColor: Colors.indigo.withOpacity(0.1),
        ),
      ],
    );
  }

  Widget _buildAISuggestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: const [
          Icon(Icons.tips_and_updates, color: Colors.amber),
          SizedBox(width: 12),
          Expanded(
            child: Text("AI khuyên bạn: Tư thế ngồi đang hơi cúi, hãy điều chỉnh lại để tránh mỏi cổ nhé!", style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// --- TRANG LỊCH SỬ (HISTORY) ---
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StudySession> sessions = [
      StudySession(id: "1", date: DateTime.now(), duration: const Duration(minutes: 45), avgFocusScore: 0.88, dominantEmotion: "Tập trung", videoPath: "/videos/1.mp4"),
      StudySession(id: "2", date: DateTime.now().subtract(const Duration(days: 1)), duration: const Duration(minutes: 30), avgFocusScore: 0.65, dominantEmotion: "Mệt mỏi", videoPath: "/videos/2.mp4"),
      StudySession(id: "3", date: DateTime.now().subtract(const Duration(days: 2)), duration: const Duration(hours: 1, minutes: 20), avgFocusScore: 0.92, dominantEmotion: "Hứng thú", videoPath: "/videos/3.mp4"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử học tập", style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final s = sessions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.play_circle_fill, color: Colors.indigo, size: 30),
              ),
              title: Text("Buổi học ${s.date.day}/${s.date.month}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Thời lượng: ${s.duration.inMinutes} phút • Cảm xúc: ${s.dominantEmotion}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${(s.avgFocusScore * 100).toInt()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const Text("Điểm", style: TextStyle(fontSize: 10)),
                ],
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPage(session: s)));
              },
            ),
          );
        },
      ),
    );
  }
}

// --- TRANG BÁO CÁO CHI TIẾT (REPORT) ---
class ReportPage extends StatelessWidget {
  final StudySession session;
  const ReportPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Báo cáo chi tiết")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, color: Colors.white54, size: 50),
                    SizedBox(height: 8),
                    Text("Xem lại video buổi học", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text("Tóm tắt kết quả", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatBox("Tập trung", "${(session.avgFocusScore * 100).toInt()}%", Colors.green),
                const SizedBox(width: 12),
                _buildStatBox("Thời gian", "${session.duration.inMinutes}m", Colors.blue),
                const SizedBox(width: 12),
                _buildStatBox("Cảm xúc", "Tốt", Colors.orange),
              ],
            ),
            
            const SizedBox(height: 32),
            const Text("Biểu đồ cảm xúc (Timeline)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Container(
              height: 100,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Container(color: Colors.green[400], child: const Center(child: Text("Vui vẻ", style: TextStyle(fontSize: 10, color: Colors.white))))),
                  Expanded(flex: 5, child: Container(color: Colors.indigo[400], child: const Center(child: Text("Tập trung", style: TextStyle(fontSize: 10, color: Colors.white))))),
                  Expanded(flex: 2, child: Container(color: Colors.red[400], child: const Center(child: Text("Bí bài", style: TextStyle(fontSize: 10, color: Colors.white))))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("00:00", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("00:${session.duration.inMinutes}:00", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),

            const SizedBox(height: 32),
            const Text("Phân tích từ AI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "Trong buổi học này, bạn duy trì sự tập trung rất tốt ở 20 phút đầu. Tuy nhiên, từ phút thứ 25, hệ thống nhận thấy bạn bắt đầu có biểu hiện mệt mỏi và hay nhìn ra ngoài. Lần sau hãy thử áp dụng phương pháp Pomodoro nhé!",
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("Tính năng $title đang được phát triển")),
    );
  }
}

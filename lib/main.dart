import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'features/home/auth_screen.dart';
import 'features/home/monitor_page.dart';
import 'features/home/history_page.dart';
import 'features/home/notification_page.dart';
import 'features/profile/profile_page.dart';
import 'features/home/value_listenable_builder_2.dart';
import 'constants/app_state.dart';
import 'package:camera/camera.dart';
import 'data/local/database_service.dart';
import 'models/video_sync_item.dart';
import 'data/local/compression_service.dart';

List<CameraDescription> _cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  availableCameras()
      .then((value) {
        _cameras = value;
      })
      .catchError((e) {
        print('Lỗi khởi tạo camera: $e');
      });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<ThemeMode, bool>(
      first: themeNotifier,
      second: isLoggedInNotifier,
      builder: (_, ThemeMode currentMode, bool isLoggedIn, __) {
        return MaterialApp(
          title: "Study Emotion Monitor",
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: isLoggedIn ? const HomePage() : const AuthScreen(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isMonitoring = false;
  CameraController? _controller;
  DateTime? _startTime;

  Future<void> _toggleMonitoring() async {
    if (_isMonitoring) {
      final XFile? videoFile = await _controller?.stopVideoRecording();
      final DateTime endTime = DateTime.now();

      if (videoFile != null) {
        _handleSavedVideo(videoFile.path, endTime);
      }

      await _controller?.dispose();
      setState(() {
        _isMonitoring = false;
        _controller = null;
      });
    } else {
      if (_cameras.isEmpty) {
        try {
          _cameras = await availableCameras();
        } catch (_) {}
        if (_cameras.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy thiết bị camera")),
          );
          return;
        }
      }

      _controller = CameraController(
        _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first,
        ),
        ResolutionPreset.medium,
      );

      try {
        await _controller!.initialize();
        await _controller!.startVideoRecording();
        _startTime = DateTime.now();

        setState(() {
          _isMonitoring = true;
        });
      } catch (e) {
        print("Camera error: $e");
      }
    }
  }

  Future<void> _handleSavedVideo(String rawPath, DateTime endTime) async {
    final String? compressedPath = await CompressionService.compressVideo(
      rawPath,
    );
    final String finalPath = compressedPath ?? rawPath;

    final int duration = _startTime != null
        ? endTime.difference(_startTime!).inSeconds
        : 0;

    await DatabaseService.instance.insertVideo(
      VideoSyncItem(
        filePath: finalPath,
        duration: duration,
        createdAt: _startTime ?? DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MonitorPage(
        isMonitoring: _isMonitoring,
        controller: _controller,
        onToggle: _toggleMonitoring,
      ),
      const HistoryPage(),
      const NotificationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard, Icons.dashboard_outlined),
            _buildNavItem(1, Icons.history, Icons.history_outlined),
            const SizedBox(width: 48),
            _buildNavItem(2, Icons.notifications, Icons.notifications_none),
            _buildNavItem(3, Icons.person, Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        isSelected ? activeIcon : inactiveIcon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
      onPressed: () => setState(() => _selectedIndex = index),
    );
  }
}

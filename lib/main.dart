import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'features/home/auth_screen.dart';
import 'features/home/monitor_page.dart';
import 'features/home/user_emotion_timeline_page.dart';
import 'features/home/notification_page.dart';
import 'features/profile/profile_page.dart';
import 'features/home/value_listenable_builder_2.dart';
import 'constants/app_state.dart';
import 'package:camera/camera.dart';

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
      builder: (_, ThemeMode currentMode, bool isLoggedIn, _) {
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

  Future<void> _toggleMonitoring() async {
    if (_isMonitoring) {
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
      MonitorPage(
        isMonitoring: _isMonitoring,
        controller: _controller,
        onToggle: _toggleMonitoring,
      ),
      const UserEmotionTimelinePage(),
      const NotificationPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard, Icons.dashboard_outlined),
            _buildNavItem(1, Icons.history, Icons.history_outlined),
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

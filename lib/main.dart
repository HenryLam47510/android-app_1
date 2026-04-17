import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/monitor_page.dart';
import 'screens/history_page.dart';
import 'screens/notification_page.dart';
import 'screens/profile_page.dart';
import 'widgets/value_listenable_builder_2.dart';
import 'constants/app_state.dart';
import 'package:camera/camera.dart';

List<CameraDescription> _cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    _cameras = await availableCameras();
  } catch (e) {
    print('Camera initialization error: $e');
    _cameras = []; 
  }
  
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
          debugShowCheckedModeBanner: false,
          title: 'AI Student Monitor',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: isLoggedIn ? const MainNavigation() : const AuthScreen(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final bool _isMonitoring = false;
  final CameraController? _controller = null;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MonitorPage(isMonitoring: _isMonitoring, controller: _controller),
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
            IconButton(
              icon: Icon(_selectedIndex == 0 ? Icons.dashboard : Icons.dashboard_outlined, color: _selectedIndex == 0 ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Icon(_selectedIndex == 1 ? Icons.history : Icons.history_outlined, color: _selectedIndex == 1 ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            const SizedBox(width: 48),
            IconButton(
              icon: Icon(_selectedIndex == 2 ? Icons.notifications : Icons.notifications_none, color: _selectedIndex == 2 ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            IconButton(
              icon: Icon(_selectedIndex == 3 ? Icons.person : Icons.person_outline, color: _selectedIndex == 3 ? Colors.indigo : Colors.grey),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_state.dart';
import '../models/user.dart';
import '../admin/admin_dashboard_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _handleAuth() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isLogin) {
      // 1. Phân vai trò (Role) khi đăng nhập
      if (email == "admin@gmail.com" && password == "123456") {
        // Tài khoản ADMIN
        currentUserNotifier.value = User(
          name: "Administrator",
          email: email,
          avatar: "https://ui-avatars.com/api/?name=Admin&background=indigo&color=fff",
        );
        isLoggedInNotifier.value = true;
        
        // Điều hướng thẳng vào trang Admin Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else if (email == "user@gmail.com" && password == "123456") {
        // Tài khoản USER
        currentUserNotifier.value = User(
          name: "Người dùng Test",
          email: email,
          avatar: "https://ui-avatars.com/api/?name=User&background=blue&color=fff",
        );
        isLoggedInNotifier.value = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email hoặc mật khẩu không đúng!\nAdmin: admin@gmail.com | User: user@gmail.com"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      // Logic Đăng ký đơn giản
      if (email.isNotEmpty && password.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")),
        );
        setState(() => _isLogin = true);
      }
    }
  }

  void _useDemoAccount(String type) {
    if (type == 'admin') {
      _emailController.text = "admin@gmail.com";
      _passwordController.text = "123456";
    } else {
      _emailController.text = "user@gmail.com";
      _passwordController.text = "123456";
    }
    setState(() => _isLogin = true);
    _handleAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              _isLogin ? "Đăng nhập hệ thống" : "Tạo tài khoản mới",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            if (!_isLogin) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isLogin ? "Đăng nhập" : "Đăng ký", style: const TextStyle(fontSize: 18)),
            ),
            
            if (_isLogin) ...[
              const SizedBox(height: 16),
              const Center(child: Text("Sử dụng tài khoản Demo:", style: TextStyle(color: Colors.grey, fontSize: 12))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _useDemoAccount('user'),
                      child: const Text("USER"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _useDemoAccount('admin'),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.indigo)),
                      child: const Text("ADMIN", style: TextStyle(color: Colors.indigo)),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Đăng nhập"),
            ),
          ],
        ),
      ),
    );
  }
}

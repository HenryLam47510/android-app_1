import 'package:flutter/material.dart';
import '../constants/app_state.dart';

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
    if (_isLogin) {
      if (_emailController.text == "admin@gmail.com" && _passwordController.text == "123456") {
        isLoggedInNotifier.value = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email hoặc mật khẩu không đúng!\nDemo: admin@gmail.com / 123456"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _nameController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")),
        );
        setState(() => _isLogin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
        );
      }
    }
  }

  void _useDemoAccount() {
    _emailController.text = "admin@gmail.com";
    _passwordController.text = "123456";
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
            const Icon(Icons.auto_awesome, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            Text(
              _isLogin ? "Chào mừng trở lại!" : "Tạo tài khoản mới",
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
                hintText: "admin@gmail.com",
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
                hintText: "123456",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_isLogin ? "Đăng nhập" : "Đăng ký", style: const TextStyle(fontSize: 18)),
            ),
            if (_isLogin) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _useDemoAccount,
                icon: const Icon(Icons.account_circle),
                label: const Text("Sử dụng tài khoản Demo"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.indigo),
                ),
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

import 'package:flutter/material.dart';
import '../constants/app_state.dart';
import '../../models/user.dart';
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
      // Logic đăng nhập cho Giáo viên (Admin)
      if (email == "admin@gmail.com" && password == "123456") {
        currentUserNotifier.value = User(
          name: "Thầy Nguyễn Văn A",
          email: email,
          avatar: "https://ui-avatars.com/api/?name=Teacher&background=3F51B5&color=fff",
        );
        isLoggedInNotifier.value = true;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } 
      // Logic đăng nhập cho Học sinh (User)
      else if (email == "user@gmail.com" && password == "123456") {
        currentUserNotifier.value = User(
          name: "Em Học Sinh",
          email: email,
          avatar: "https://ui-avatars.com/api/?name=Student&background=03A9F4&color=fff",
        );
        isLoggedInNotifier.value = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thông tin đăng nhập chưa đúng rồi!"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      if (email.isNotEmpty && password.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký tài khoản học sinh thành công! ✨")),
        );
        setState(() => _isLogin = true);
      }
    }
  }

  void _useDemoAccount(String role) {
    if (role == 'admin') {
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
      backgroundColor: Colors.blueGrey[50], // Nền trung tính sạch sẽ
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo Trường Học
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school_rounded, size: 80, color: Colors.indigo),
              ),
              const SizedBox(height: 20),
              const Text(
                "CỔNG HỌC TẬP THÔNG MINH",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.indigo,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                "Chắp cánh ước mơ học đường",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.blueGrey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),

              // Form Nhập liệu
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        _isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ HỌC VIÊN",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 20),
                      if (!_isLogin) ...[
                        _buildTextField(_nameController, "Họ và tên em", Icons.person_outline),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(_emailController, "Tên tài khoản / Email", Icons.account_circle_outlined),
                      const SizedBox(height: 16),
                      _buildTextField(_passwordController, "Mật khẩu", Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 30),
                      
                      // Nút hành động chính
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                          ),
                          child: Text(
                            _isLogin ? "VÀO LỚP NGAY" : "XÁC NHẬN ĐĂNG KÝ",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              // Khu vực chọn nhanh vai trò (Demo)
              if (_isLogin) ...[
                const Center(
                  child: Text(
                    "BẠN ĐĂNG NHẬP VỚI VAI TRÒ:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleButton(
                        "HỌC SINH", 
                        Icons.child_care, 
                        Colors.lightBlue, 
                        () => _useDemoAccount('user')
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleButton(
                        "GIÁO VIÊN", 
                        Icons.assignment_ind, 
                        Colors.indigo, 
                        () => _useDemoAccount('admin')
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? "Em chưa có tài khoản? Đăng ký tại đây" : "Đã có tài khoản? Quay lại đăng nhập",
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildRoleButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

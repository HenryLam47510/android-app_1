import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      // Logic kiểm tra mật khẩu hiện tại (giả lập là 123456)
      if (_currentPasswordController.text != "123456") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mật khẩu hiện tại không đúng!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Logic kiểm tra khớp mật khẩu mới
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mật khẩu xác nhận không khớp!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Giả lập đổi mật khẩu thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đổi mật khẩu thành công!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bảo mật & Mật khẩu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Đổi mật khẩu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Mật khẩu của bạn nên có ít nhất 6 ký tự để đảm bảo an toàn.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // Mật khẩu hiện tại
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu hiện tại",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mật khẩu hiện tại";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Mật khẩu mới
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu mới",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Mật khẩu phải có ít nhất 6 ký tự";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Xác nhận mật khẩu mới
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Xác nhận mật khẩu mới",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng xác nhận mật khẩu mới";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cập nhật mật khẩu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '/constants/app_state.dart';
import '../profile/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController avatarController;

  @override
  void initState() {
    super.initState();
    final currentUser = currentUserNotifier.value;
    nameController = TextEditingController(text: currentUser.name);
    emailController = TextEditingController(text: currentUser.email);
    avatarController = TextEditingController(text: currentUser.avatar);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      currentUserNotifier.value = User(
        name: nameController.text,
        email: emailController.text,
        avatar: avatarController.text,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thông tin của em đã được lưu lại rồi nhé! ✨"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("HỒ SƠ CỦA EM", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
<<<<<<< HEAD:lib/features/profile/edit_profile_page.dart
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      avatarController.text.isNotEmpty
                          ? avatarController.text
                          : "https://ui-avatars.com/api/?name=${nameController.text}",
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
=======
              // Khu vực Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: NetworkImage(avatarController.text.isNotEmpty 
                          ? avatarController.text 
                          : "https://ui-avatars.com/api/?name=${nameController.text}&background=random"),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
>>>>>>> dec10dc6eff067edfefdec2e9ff6fc1baab9fb21:lib/screens/edit_profile_page.dart
              ),
              const SizedBox(height: 32),

              // Thẻ thông tin
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Thông tin cá nhân",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: nameController,
                        label: "Tên của em là gì?",
                        icon: Icons.face_outlined,
                        hint: "Ví dụ: Nguyễn Văn A",
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: emailController,
                        label: "Địa chỉ Email / Tên đăng nhập",
                        icon: Icons.alternate_email,
                        hint: "Ví dụ: emhocsinh@gmail.com",
                        validator: (value) => (value == null || !value.contains("@")) ? "Email chưa đúng định dạng em ơi" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: avatarController,
                        label: "Link ảnh đại diện của em",
                        icon: Icons.image_search_outlined,
                        hint: "Dán link ảnh tại đây",
                        onChanged: (value) => setState(() {}),
                      ),
                    ],
                  ),
                ),
<<<<<<< HEAD:lib/features/profile/edit_profile_page.dart
                validator: (value) => (value == null || value.isEmpty)
                    ? "Vui lòng nhập tên"
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) => (value == null || !value.contains("@"))
                    ? "Email không hợp lệ"
                    : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: avatarController,
                decoration: const InputDecoration(
                  labelText: "Avatar URL (Link ảnh)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                onChanged: (value) =>
                    setState(() {}), // Để cập nhật ảnh preview phía trên
=======
>>>>>>> dec10dc6eff067edfefdec2e9ff6fc1baab9fb21:lib/screens/edit_profile_page.dart
              ),

              const SizedBox(height: 40),
              
              // Nút lưu
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("LƯU THAY ĐỔI NHÉ!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
<<<<<<< HEAD:lib/features/profile/edit_profile_page.dart
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Lưu thay đổi",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
=======
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
>>>>>>> dec10dc6eff067edfefdec2e9ff6fc1baab9fb21:lib/screens/edit_profile_page.dart
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Quay lại trang trước", style: TextStyle(color: Colors.blueGrey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator ?? (value) => (value == null || value.isEmpty) ? "Ô này không được để trống em nhé" : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.indigo[300]),
        filled: true,
        fillColor: Colors.blue[50]?.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
    );
  }
}

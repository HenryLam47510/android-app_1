import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../constants/app_state.dart';
import '../../data/remote/api_service.dart';
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
  PlatformFile? _selectedAvatar;
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

  bool _isValidImageFile(PlatformFile file) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = file.name.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final currentUser = currentUserNotifier.value;
      // Nếu người dùng đã chọn file avatar mới, upload trước
      Future<void> doUpdate() async {
        String avatarUrl = avatarController.text;
        if (_selectedAvatar != null) {
          try {
            if (!_isValidImageFile(_selectedAvatar!)) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Chỉ hỗ trợ các định dạng: JPG, PNG, GIF, WebP, BMP',
                    ),
                  ),
                );
              }
              return;
            }

            final uploadedUrl = await ApiService.uploadUserAvatar(
              userId: currentUser.id,
              bytes: _selectedAvatar!.bytes,
              filename: _selectedAvatar!.name,
              path: _selectedAvatar!.path,
            );
            avatarUrl = uploadedUrl;
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Lỗi upload avatar: $e')));
            }
            return;
          }
        }

        currentUserNotifier.value = User(
          id: currentUser.id,
          name: nameController.text,
          email: emailController.text,
          avatar: avatarUrl,
          role: currentUser.role,
        );

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Thông tin đã được cập nhật!")),
          );
        }
      }

      doUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa thông tin")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                  if (_selectedAvatar != null)
                    Positioned.fill(
                      child: ClipOval(
                        child: Image.memory(
                          _selectedAvatar!.bytes!,
                          fit: BoxFit.cover,
                        ),
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
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: [
                          'jpg',
                          'jpeg',
                          'png',
                          'gif',
                          'webp',
                          'bmp',
                        ],
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        if (_isValidImageFile(file)) {
                          setState(() {
                            _selectedAvatar = file;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã chọn: ${file.name}')),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'File không hợp lệ. Vui lòng chọn ảnh.',
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Chọn ảnh avatar'),
                  ),
                  if (_selectedAvatar != null)
                    Chip(
                      label: Text(
                        _selectedAvatar!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onDeleted: () {
                        setState(() {
                          _selectedAvatar = null;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Họ và tên",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
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
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Lưu thay đổi",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

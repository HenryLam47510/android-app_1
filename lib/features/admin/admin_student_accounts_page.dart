import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/remote/api_service.dart';

class AdminStudentAccountsPage extends StatefulWidget {
  const AdminStudentAccountsPage({super.key});

  @override
  State<AdminStudentAccountsPage> createState() =>
      _AdminStudentAccountsPageState();
}

class _AdminStudentAccountsPageState extends State<AdminStudentAccountsPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAdminUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = ApiService.getAdminUsers();
    });
    await _usersFuture;
  }

  String _userInitials(Map<String, dynamic> user) {
    final name = user['name']?.toString() ?? '';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0].toUpperCase()}${parts.last[0].toUpperCase()}';
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    final avatarUrl = user['avatar_url']?.toString();
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(avatarUrl),
        backgroundColor: Colors.grey[200],
      );
    }
    return CircleAvatar(
      backgroundColor: Colors.indigo,
      child: Text(
        _userInitials(user),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Future<void> _showUserFormDialog({Map<String, dynamic>? user}) async {
    final nameController = TextEditingController(
      text: user?['name']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: user?['email']?.toString() ?? '',
    );
    final passwordController = TextEditingController();
    String selectedRole = user?['role']?.toString() ?? 'student';
    PlatformFile? selectedAvatar;

    final isEditing = user != null;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Sửa tài khoản' : 'Thêm tài khoản'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Tên'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: isEditing
                            ? 'Mật khẩu mới (nếu muốn)'
                            : 'Mật khẩu',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: 'Vai trò'),
                      items: const [
                        DropdownMenuItem(
                          value: 'student',
                          child: Text('Student'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          selectedRole = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setState(() {
                            selectedAvatar = result.files.first;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo),
                      label: const Text('Chọn avatar'),
                    ),
                    if (selectedAvatar != null) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: ClipOval(
                          child: Image.memory(
                            selectedAvatar!.bytes!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) {
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      int userId;
      if (isEditing) {
        final updatedUser = await ApiService.updateAdminUser(
          userId: user!['id'] as int,
          name: name,
          email: email,
          password: password.isNotEmpty ? password : null,
          role: selectedRole,
        );
        userId = updatedUser['id'] as int;
      } else {
        if (password.isEmpty) {
          throw Exception('Mật khẩu không được bỏ trống');
        }
        final createdUser = await ApiService.createAdminUser(
          name: name,
          email: email,
          password: password,
          role: selectedRole,
        );
        userId = createdUser['id'] as int;
      }

      if (selectedAvatar != null) {
        await ApiService.uploadAdminUserAvatar(
          userId: userId,
          bytes: selectedAvatar!.bytes,
          filename: selectedAvatar!.name,
          path: selectedAvatar!.path,
        );
      }

      _hasChanges = true;
      await _refreshUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu tài khoản: $e')));
      }
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> user) async {
    final userName = user['name']?.toString() ?? 'tài khoản này';
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa tài khoản "$userName" không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
    if (result != true) {
      return;
    }

    try {
      final success = await ApiService.deleteAdminUser(user['id'] as int);
      if (!success) {
        throw Exception('Xóa tài khoản không thành công');
      }
      _hasChanges = true;
      await _refreshUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi xóa tài khoản: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Học sinh'),
          backgroundColor: Colors.indigo,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showUserFormDialog(),
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add),
          tooltip: 'Thêm tài khoản',
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Danh sách tài khoản học sinh hiện tại trong DB',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshUsers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Tải lại',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Không thể tải danh sách tài khoản: ${snapshot.error}',
                        ),
                      );
                    }
                    final users = snapshot.data ?? [];
                    if (users.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không có tài khoản học sinh trong hệ thống.',
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: _buildAvatar(user),
                          title: Text(user['name']?.toString() ?? 'Không tên'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${user['email'] ?? '-'}'),
                              Text('Vai trò: ${user['role'] ?? '-'}'),
                              Text('ID: ${user['id'] ?? '-'}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.indigo,
                                ),
                                onPressed: () =>
                                    _showUserFormDialog(user: user),
                                tooltip: 'Sửa',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(user),
                                tooltip: 'Xóa',
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ), // đóng Scaffold
    ); // đóng WillPopScope
  }
}

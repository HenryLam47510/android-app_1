import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../models/student.dart';

const String _storageKey = 'student_list_data';

class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  _StudentManagementPageState createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);

    if (storedData != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(storedData);
        students = jsonList.map((item) => Student.fromJson(item)).toList();
      } catch (e) {
        print('Lỗi load sinh viên: $e');
        // Nếu lỗi, load dữ liệu mẫu
        _loadSampleData();
      }
    } else {
      // Lần đầu tiên, load dữ liệu mẫu
      _loadSampleData();
    }

    setState(() {});
  }

  void _loadSampleData() {
    students = [
      Student(
        id: 's1',
        name: 'Nguyễn Văn A',
        email: 'a@student.com',
        phoneNumber: '0987654321',
        classId: 'AI01',
        status: 'Đang học',
        attendanceRate: 92.5,
        attendanceHistory: ['Điểm danh 07/05', 'Điểm danh 06/05'],
        faceImageUrls: [],
      ),
      Student(
        id: 's2',
        name: 'Trần Thị B',
        email: 'b@student.com',
        phoneNumber: '0912345678',
        classId: 'AI01',
        status: 'Tạm nghỉ',
        attendanceRate: 78.0,
        attendanceHistory: ['Điểm danh 07/05', 'Vắng 06/05'],
        faceImageUrls: [],
      ),
    ];
    _saveStudents();
  }

  Future<void> _saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(students.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, jsonData);
  }

  void _addStudent() {
    Navigator.push<Student?>(
      context,
      MaterialPageRoute(builder: (context) => StudentFormPage()),
    ).then((newStudent) async {
      if (newStudent != null) {
        setState(() {
          students.add(newStudent);
        });
        await _saveStudents();
      }
    });
  }

  void _editStudent(Student student) {
    Navigator.push<Student?>(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFormPage(student: student),
      ),
    ).then((updatedStudent) async {
      if (updatedStudent != null) {
        setState(() {
          final index = students.indexWhere((s) => s.id == updatedStudent.id);
          if (index >= 0) {
            students[index] = updatedStudent;
          }
        });
        await _saveStudents();
      }
    });
  }

  void _deleteStudent(Student student) async {
    // Confirm delete
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có muốn xóa sinh viên ${student.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      setState(() {
        students.removeWhere((s) => s.id == student.id);
      });
      await _saveStudents();
    }
  }

  Future<void> _importExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final importedStudents = await _parseExcelFile(filePath);

        if (importedStudents.isNotEmpty) {
          _showImportDialog(importedStudents);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'File Excel không chứa dữ liệu sinh viên hợp lệ.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi import: $e')));
      }
    }
  }

  Future<List<Student>> _parseExcelFile(String filePath) async {
    final importedStudents = <Student>[];
    try {
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        final rows = sheet.rows;

        // Skip header row (first row)
        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty) continue;

          try {
            // Expected columns: Tên, Email, SĐT, Lớp, Trạng thái
            final name = row.length > 0
                ? row[0]?.value?.toString().trim() ?? ''
                : '';
            final email = row.length > 1
                ? row[1]?.value?.toString().trim() ?? ''
                : '';
            final phone = row.length > 2
                ? row[2]?.value?.toString().trim() ?? ''
                : '';
            final classId = row.length > 3
                ? row[3]?.value?.toString().trim() ?? ''
                : '';
            final status = row.length > 4
                ? row[4]?.value?.toString().trim() ?? 'Đang học'
                : 'Đang học';

            if (name.isNotEmpty && email.isNotEmpty) {
              final student = Student(
                id:
                    DateTime.now().millisecondsSinceEpoch.toString() +
                    i.toString(),
                name: name,
                email: email,
                phoneNumber: phone,
                classId: classId,
                status: status,
              );
              importedStudents.add(student);
            }
          } catch (e) {
            print('Lỗi parse dòng $i: $e');
          }
        }
      }
    } catch (e) {
      print('Lỗi đọc file Excel: $e');
    }

    return importedStudents;
  }

  void _showImportDialog(List<Student> importedStudents) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Import Sinh viên'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sắp import ${importedStudents.length} sinh viên',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Danh sách sinh viên:'),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: importedStudents.length,
                  itemBuilder: (context, index) {
                    final student = importedStudents[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${index + 1}. ${student.name} (${student.email})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Những sinh viên này sẽ được thêm vào danh sách hiện tại.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _addImportedStudents(importedStudents);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _addImportedStudents(List<Student> importedStudents) async {
    setState(() {
      students.addAll(importedStudents);
    });
    await _saveStudents();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã import thành công ${importedStudents.length} sinh viên.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sinh viên'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import Excel',
            onPressed: _importExcel,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset dữ liệu AI',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã reset dữ liệu nhận diện khuôn mặt AI.'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: student.avatarUrl != null && !kIsWeb
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(student.avatarUrl!)),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text(
                        student.name.isEmpty
                            ? '?'
                            : student.name[0].toUpperCase(),
                      ),
                    ),
              title: Text(student.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.email),
                  Text('SĐT: ${student.phoneNumber}'),
                  Text('Lớp: ${student.classId} • ${student.status}'),
                  Text(
                    'Chuyên cần: ${student.attendanceRate.toStringAsFixed(0)}%',
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editStudent(student),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteStudent(student),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StudentFormPage extends StatefulWidget {
  final Student? student;

  const StudentFormPage({super.key, this.student});

  @override
  _StudentFormPageState createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _classIdController;
  late TextEditingController _statusController;
  late TextEditingController _attendanceRateController;
  String? _avatarUrl;
  List<String> _faceImageUrls = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.name ?? '');
    _emailController = TextEditingController(text: widget.student?.email ?? '');
    _phoneController = TextEditingController(
      text: widget.student?.phoneNumber ?? '',
    );
    _classIdController = TextEditingController(
      text: widget.student?.classId ?? '',
    );
    _statusController = TextEditingController(
      text: widget.student?.status ?? 'Đang học',
    );
    _attendanceRateController = TextEditingController(
      text: widget.student?.attendanceRate.toStringAsFixed(0) ?? '0',
    );
    _avatarUrl = widget.student?.avatarUrl;
    _faceImageUrls = widget.student?.faceImageUrls ?? [];
  }

  void _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _avatarUrl = pickedFile.path;
      setState(() {});
    }
  }

  void _pickFaceImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      _faceImageUrls = pickedFiles.map((file) => file.path).toList();
      setState(() {});
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final student = Student(
        id: widget.student?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        classId: _classIdController.text,
        status: _statusController.text,
        avatarUrl: _avatarUrl,
        faceImageUrls: _faceImageUrls,
        attendanceRate: double.tryParse(_attendanceRateController.text) ?? 0.0,
        attendanceHistory: widget.student?.attendanceHistory ?? [],
      );
      // await ApiService.saveStudent(student);
      Navigator.pop(context, student);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.student == null ? 'Thêm Sinh viên' : 'Sửa Sinh viên',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập email' : null,
              ),
              TextFormField(
                controller: _classIdController,
                decoration: const InputDecoration(labelText: 'ID Lớp'),
                validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập ID lớp' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái học tập',
                ),
              ),
              TextFormField(
                controller: _attendanceRateController,
                decoration: const InputDecoration(
                  labelText: 'Điểm chuyên cần (%)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Avatar sinh viên'),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickAvatar,
                    child: const Text('Chọn Avatar'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _avatarUrl != null
                          ? 'Avatar: ${_avatarUrl!.split('/').last}'
                          : 'Chưa có avatar',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_avatarUrl != null) ...[
                const SizedBox(height: 12),
                if (!kIsWeb)
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_avatarUrl!), fit: BoxFit.cover),
                    ),
                  ),
                if (kIsWeb)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Avatar lưu để hiển thị khi chạy bản native.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              const Text('Ảnh khuôn mặt (Face Enrollment)'),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickFaceImages,
                    child: const Text('Chọn nhiều ảnh'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _faceImageUrls.isNotEmpty
                          ? 'Đã chọn ${_faceImageUrls.length} ảnh'
                          : 'Chưa có ảnh khuôn mặt',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_faceImageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _faceImageUrls.map((path) {
                    return Chip(label: Text(path.split('/').last));
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../models/subject.dart';
import '../../models/lecturer.dart';
import '../../models/student.dart';
import 'student_management_page.dart';

class ClassManagementPage extends StatefulWidget {
  const ClassManagementPage({super.key});

  @override
  _ClassManagementPageState createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassModel> classes = [];
  List<Subject> subjects = [];
  List<Lecturer> lecturers = [];
  List<Student> students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 200));

    lecturers = [
      Lecturer(id: 't1', name: 'Nguyễn Văn Hùng', email: 'hung@example.com'),
      Lecturer(id: 't2', name: 'Lê Thị Mai', email: 'mai@example.com'),
    ];

    subjects = [
      Subject(
        id: 'sub1',
        code: 'AI101',
        name: 'Trí tuệ nhân tạo',
        description: 'Cơ bản về AI, học máy và nhận diện khuôn mặt.',
        lecturerId: 't1',
        managerIds: ['t1'],
        activityLogs: ['Tạo môn ngày 01/04', 'Cập nhật mô tả ngày 05/04'],
      ),
      Subject(
        id: 'sub2',
        code: 'WEB202',
        name: 'Lập trình Web',
        description: 'Thiết kế giao diện và backend cho ứng dụng học tập.',
        lecturerId: 't2',
        managerIds: ['t2'],
        activityLogs: ['Tạo môn ngày 10/04', 'Thay đổi giảng viên ngày 12/04'],
      ),
    ];

    students = [
      Student(
        id: 's1',
        name: 'Nguyễn Văn A',
        email: 'a@student.com',
        phoneNumber: '0987654321',
        classId: 'AI01',
        status: 'Đang học',
        attendanceRate: 92.0,
        attendanceHistory: ['07/05: Có mặt', '06/05: Có mặt'],
      ),
      Student(
        id: 's2',
        name: 'Trần Thị B',
        email: 'b@student.com',
        phoneNumber: '0912345678',
        classId: 'AI01',
        status: 'Đang học',
        attendanceRate: 88.0,
        attendanceHistory: ['07/05: Có mặt', '06/05: Vắng'],
      ),
      Student(
        id: 's3',
        name: 'Phạm Văn C',
        email: 'c@student.com',
        phoneNumber: '0933344455',
        classId: 'WEB02',
        status: 'Đang học',
        attendanceRate: 95.0,
        attendanceHistory: ['07/05: Có mặt', '06/05: Có mặt'],
      ),
    ];

    classes = [
      ClassModel(
        id: 'c1',
        name: 'Lớp AI01',
        code: 'AI01',
        subjectId: 'sub1',
        lecturerId: 't1',
        maxSize: 30,
        schedule: 'Thứ 2, Thứ 4 8:00-10:00\nPhòng A101',
        attendanceWindowMinutes: 10,
        faceThreshold: 0.75,
        studentIds: ['s1', 's2'],
        managerIds: ['t1'],
        attendanceRate: 92.5,
        totalSessions: 12,
        activityLogs: ['Tạo lớp ngày 01/04', 'Sửa lịch học ngày 15/04'],
      ),
      ClassModel(
        id: 'c2',
        name: 'Lớp Web02',
        code: 'WEB02',
        subjectId: 'sub2',
        lecturerId: 't2',
        maxSize: 28,
        schedule: 'Thứ 3, Thứ 5 13:00-15:00\nPhòng B204',
        attendanceWindowMinutes: 5,
        faceThreshold: 0.80,
        studentIds: ['s3'],
        managerIds: ['t2'],
        attendanceRate: 88.0,
        totalSessions: 10,
        activityLogs: [
          'Tạo lớp ngày 05/04',
          'Cập nhật ngưỡng nhận diện ngày 20/04',
        ],
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  void _addItem() {
    if (_tabController.index == 0) {
      _addClass();
    } else if (_tabController.index == 1) {
      _addSubject();
    } else {
      _addStudent();
    }
  }

  void _addClass() {
    Navigator.push<ClassModel>(
      context,
      MaterialPageRoute(
        builder: (context) => ClassFormPage(
          subjects: subjects,
          lecturers: lecturers,
          students: students,
        ),
      ),
    ).then((newClass) {
      if (newClass != null) {
        setState(() {
          classes.add(newClass);
        });
      }
    });
  }

  void _editClass(ClassModel classModel) {
    Navigator.push<ClassModel>(
      context,
      MaterialPageRoute(
        builder: (context) => ClassFormPage(
          classModel: classModel,
          subjects: subjects,
          lecturers: lecturers,
          students: students,
        ),
      ),
    ).then((updatedClass) {
      if (updatedClass != null) {
        setState(() {
          final index = classes.indexWhere((c) => c.id == updatedClass.id);
          if (index >= 0) {
            classes[index] = updatedClass;
          }
        });
      }
    });
  }

  void _addStudent() {
    Navigator.push<Student>(
      context,
      MaterialPageRoute(builder: (context) => const StudentFormPage()),
    ).then((newStudent) {
      if (newStudent != null) {
        setState(() {
          students.add(newStudent);
        });
      }
    });
  }

  void _editStudent(Student student) {
    Navigator.push<Student>(
      context,
      MaterialPageRoute(
        builder: (context) => StudentFormPage(student: student),
      ),
    ).then((updatedStudent) {
      if (updatedStudent != null) {
        setState(() {
          final index = students.indexWhere((s) => s.id == updatedStudent.id);
          if (index >= 0) {
            students[index] = updatedStudent;
          }
        });
      }
    });
  }

  void _deleteStudent(Student student) async {
    final confirm =
        await showDialog<bool>(
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
    }
  }

  void _deleteClass(ClassModel classModel) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có muốn xóa lớp ${classModel.name}?'),
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
        classes.removeWhere((c) => c.id == classModel.id);
      });
    }
  }

  void _addSubject() {
    Navigator.push<Subject>(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectFormPage(lecturers: lecturers),
      ),
    ).then((newSubject) {
      if (newSubject != null) {
        setState(() {
          subjects.add(newSubject);
        });
      }
    });
  }

  void _editSubject(Subject subject) {
    Navigator.push<Subject>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SubjectFormPage(subject: subject, lecturers: lecturers),
      ),
    ).then((updatedSubject) {
      if (updatedSubject != null) {
        setState(() {
          final index = subjects.indexWhere((s) => s.id == updatedSubject.id);
          if (index >= 0) {
            subjects[index] = updatedSubject;
          }
        });
      }
    });
  }

  void _deleteSubject(Subject subject) async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có muốn xóa môn ${subject.name}?'),
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
        subjects.removeWhere((s) => s.id == subject.id);
      });
    }
  }

  void _exportAttendanceReport(ClassModel classModel) {
    final subject = subjects.firstWhere(
      (s) => s.id == classModel.subjectId,
      orElse: () => Subject(
        id: '',
        code: '',
        name: 'Không xác định',
        description: '',
        lecturerId: '',
        managerIds: [],
        activityLogs: [],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Xuất báo cáo điểm danh cho ${classModel.name} - ${subject.name} thành công.',
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildClassTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classModel = classes[index];
        final subject = subjects.firstWhere(
          (s) => s.id == classModel.subjectId,
          orElse: () => Subject(
            id: '',
            code: '',
            name: 'Không xác định',
            description: '',
            lecturerId: '',
            managerIds: [],
            activityLogs: [],
          ),
        );
        final lecturer = lecturers.firstWhere(
          (l) => l.id == classModel.lecturerId,
          orElse: () => Lecturer(id: '', name: 'Không xác định', email: ''),
        );
        final classStudents = students
            .where((student) => classModel.studentIds.contains(student.id))
            .toList();
        final managers = lecturers
            .where((lecturer) => classModel.managerIds.contains(lecturer.id))
            .map((l) => l.name)
            .join(', ');

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Text('${classModel.name} (${classModel.code})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Môn: ${subject.name}  •  Giảng viên: ${lecturer.name}'),
                Text(
                  'Sĩ số: ${classStudents.length}/${classModel.maxSize} • Chuyên cần: ${classModel.attendanceRate}% • Buổi: ${classModel.totalSessions}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Lịch học', classModel.schedule),
                    _buildDetailRow(
                      'Thời gian điểm danh',
                      '${classModel.attendanceWindowMinutes} phút đầu',
                    ),
                    _buildDetailRow(
                      'Ngưỡng nhận diện',
                      '${(classModel.faceThreshold * 100).toStringAsFixed(0)}%',
                    ),
                    _buildDetailRow(
                      'Quản lý',
                      managers.isEmpty ? 'Chưa có' : managers,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sinh viên trong lớp',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: classStudents.map((student) {
                        return Chip(
                          label: Text(student.name),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nhật ký hoạt động',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...classModel.activityLogs.map(
                      (log) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('• $log'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _exportAttendanceReport(classModel),
                          child: const Text('Xuất báo cáo'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editClass(classModel),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteClass(classModel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ListTile(
            title: Text(student.name),
            subtitle: Text('${student.email}\nLớp: ${student.classId}'),
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
    );
  }

  Widget _buildSubjectTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final lecturer = lecturers.firstWhere(
          (l) => l.id == subject.lecturerId,
          orElse: () => Lecturer(id: '', name: 'Không xác định', email: ''),
        );
        final managers = lecturers
            .where((lecturer) => subject.managerIds.contains(lecturer.id))
            .map((l) => l.name)
            .join(', ');

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Text('${subject.name} (${subject.code})'),
            subtitle: Text('Giảng viên: ${lecturer.name}'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Mô tả', subject.description),
                    _buildDetailRow(
                      'Quản lý',
                      managers.isEmpty ? 'Chưa có' : managers,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nhật ký hoạt động',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...subject.activityLogs.map(
                      (log) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('• $log'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _editSubject(subject),
                          child: const Text('Sửa'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteSubject(subject),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Lớp học & Môn học'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Lớp học'),
            Tab(text: 'Môn học'),
            Tab(text: 'Sinh viên'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildClassTab(),
                _buildSubjectTab(),
                _buildStudentTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ClassFormPage extends StatefulWidget {
  final ClassModel? classModel;
  final List<Subject> subjects;
  final List<Lecturer> lecturers;
  final List<Student> students;

  const ClassFormPage({
    super.key,
    this.classModel,
    required this.subjects,
    required this.lecturers,
    required this.students,
  });

  @override
  _ClassFormPageState createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _maxSizeController;
  late TextEditingController _scheduleController;
  late TextEditingController _attendanceWindowController;
  late TextEditingController _faceThresholdController;
  String? _selectedSubjectId;
  String? _selectedLecturerId;
  List<String> _selectedStudentIds = [];
  List<String> _selectedManagerIds = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.classModel?.name ?? '',
    );
    _codeController = TextEditingController(
      text: widget.classModel?.code ?? '',
    );
    _maxSizeController = TextEditingController(
      text: widget.classModel?.maxSize.toString() ?? '30',
    );
    _scheduleController = TextEditingController(
      text: widget.classModel?.schedule ?? '',
    );
    _attendanceWindowController = TextEditingController(
      text: widget.classModel?.attendanceWindowMinutes.toString() ?? '10',
    );
    _faceThresholdController = TextEditingController(
      text: widget.classModel?.faceThreshold.toString() ?? '0.75',
    );
    _selectedSubjectId = widget.classModel?.subjectId;
    _selectedLecturerId = widget.classModel?.lecturerId;
    _selectedStudentIds = widget.classModel?.studentIds ?? [];
    _selectedManagerIds = widget.classModel?.managerIds ?? [];
  }

  void _toggleSelection(String id, List<String> list) {
    setState(() {
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final classModel = ClassModel(
        id: widget.classModel?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        code: _codeController.text,
        subjectId: _selectedSubjectId ?? '',
        lecturerId: _selectedLecturerId ?? '',
        maxSize: int.tryParse(_maxSizeController.text) ?? 30,
        schedule: _scheduleController.text,
        attendanceWindowMinutes:
            int.tryParse(_attendanceWindowController.text) ?? 10,
        faceThreshold: double.tryParse(_faceThresholdController.text) ?? 0.75,
        studentIds: List.from(_selectedStudentIds),
        managerIds: List.from(_selectedManagerIds),
        attendanceRate: widget.classModel?.attendanceRate ?? 0.0,
        totalSessions: widget.classModel?.totalSessions ?? 0,
        activityLogs: [
          if (widget.classModel != null) ...widget.classModel!.activityLogs,
          'Lưu lớp học vào ${DateTime.now()}',
        ],
      );
      Navigator.pop(context, classModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classModel == null ? 'Thêm Lớp' : 'Sửa Lớp'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên Lớp'),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên lớp' : null,
                ),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Mã Lớp'),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập mã lớp' : null,
                ),
                TextFormField(
                  controller: _maxSizeController,
                  decoration: const InputDecoration(labelText: 'Sĩ số tối đa'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập sĩ số tối đa' : null,
                ),
                TextFormField(
                  controller: _scheduleController,
                  decoration: const InputDecoration(
                    labelText: 'Lịch học',
                    hintText: 'Thứ 2/4 8:00-10:00, Phòng A101',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập lịch học' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  decoration: const InputDecoration(labelText: 'Môn học'),
                  items: widget.subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject.id,
                      child: Text('${subject.name} (${subject.code})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedSubjectId = value;
                  }),
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn môn học' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedLecturerId,
                  decoration: const InputDecoration(labelText: 'Giảng viên'),
                  items: widget.lecturers.map((lecturer) {
                    return DropdownMenuItem(
                      value: lecturer.id,
                      child: Text(lecturer.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedLecturerId = value;
                  }),
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn giảng viên' : null,
                ),
                TextFormField(
                  controller: _attendanceWindowController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian điểm danh (phút)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty
                      ? 'Vui lòng nhập thời gian điểm danh'
                      : null,
                ),
                TextFormField(
                  controller: _faceThresholdController,
                  decoration: const InputDecoration(
                    labelText: 'Ngưỡng nhận diện khuôn mặt',
                    hintText: 'Ví dụ: 0.75',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập ngưỡng nhận diện' : null,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chọn quản lý lớp',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: widget.lecturers.map((lecturer) {
                    return CheckboxListTile(
                      title: Text(lecturer.name),
                      value: _selectedManagerIds.contains(lecturer.id),
                      onChanged: (_) =>
                          _toggleSelection(lecturer.id, _selectedManagerIds),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Danh sách sinh viên',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.students.map((student) {
                    final selected = _selectedStudentIds.contains(student.id);
                    return ChoiceChip(
                      label: Text(student.name),
                      selected: selected,
                      onSelected: (_) =>
                          _toggleSelection(student.id, _selectedStudentIds),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _save, child: const Text('Lưu')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubjectFormPage extends StatefulWidget {
  final Subject? subject;
  final List<Lecturer> lecturers;

  const SubjectFormPage({super.key, this.subject, required this.lecturers});

  @override
  _SubjectFormPageState createState() => _SubjectFormPageState();
}

class _SubjectFormPageState extends State<SubjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  String? _selectedLecturerId;
  List<String> _selectedManagerIds = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject?.name ?? '');
    _codeController = TextEditingController(text: widget.subject?.code ?? '');
    _descriptionController = TextEditingController(
      text: widget.subject?.description ?? '',
    );
    _selectedLecturerId = widget.subject?.lecturerId;
    _selectedManagerIds = widget.subject?.managerIds ?? [];
  }

  void _toggleSelection(String id, List<String> list) {
    setState(() {
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
    });
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final subject = Subject(
        id: widget.subject?.id ?? DateTime.now().toString(),
        code: _codeController.text,
        name: _nameController.text,
        description: _descriptionController.text,
        lecturerId: _selectedLecturerId ?? '',
        managerIds: List.from(_selectedManagerIds),
        activityLogs: [
          if (widget.subject != null) ...widget.subject!.activityLogs,
          'Lưu môn học vào ${DateTime.now()}',
        ],
      );
      Navigator.pop(context, subject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject == null ? 'Thêm Môn học' : 'Sửa Môn học'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên Môn'),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập tên môn' : null,
                ),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Mã Môn'),
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập mã môn' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  minLines: 2,
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập mô tả môn' : null,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedLecturerId,
                  decoration: const InputDecoration(labelText: 'Giảng viên'),
                  items: widget.lecturers.map((lecturer) {
                    return DropdownMenuItem(
                      value: lecturer.id,
                      child: Text(lecturer.name),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    _selectedLecturerId = value;
                  }),
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn giảng viên' : null,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quản lý môn học',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: widget.lecturers.map((lecturer) {
                    return CheckboxListTile(
                      title: Text(lecturer.name),
                      value: _selectedManagerIds.contains(lecturer.id),
                      onChanged: (_) =>
                          _toggleSelection(lecturer.id, _selectedManagerIds),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _save, child: const Text('Lưu')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

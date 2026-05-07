class Lecturer {
  final String id;
  final String name;
  final String email;

  Lecturer({required this.id, required this.name, required this.email});

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

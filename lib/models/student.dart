class Student {
  final String name;
  final String email;
  final String rollNumber;
  final String department;
  final String yearOfStudy;
  final String phone;
  final String avatarUrl;

  const Student({
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.department,
    required this.yearOfStudy,
    required this.phone,
    this.avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String? ?? 'Alex Chen',
      email: json['email'] as String? ?? 'alex.chen@campus.edu',
      rollNumber: json['rollNumber'] as String? ?? 'CS-2023-042',
      department: json['department'] as String? ?? 'Computer Science & Engineering',
      yearOfStudy: json['yearOfStudy'] as String? ?? '3rd Year (Junior)',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      avatarUrl: json['avatarUrl'] as String? ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'rollNumber': rollNumber,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }

  Student copyWith({
    String? name,
    String? email,
    String? rollNumber,
    String? department,
    String? yearOfStudy,
    String? phone,
    String? avatarUrl,
  }) {
    return Student(
      name: name ?? this.name,
      email: email ?? this.email,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  static const Student defaultDemoStudent = Student(
    name: 'Alex Chen',
    email: 'alex.chen@campusverse.edu',
    rollNumber: 'CS-2023-042',
    department: 'Computer Science & Engineering',
    yearOfStudy: '3rd Year (Junior)',
    phone: '+91 98765 43210',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
  );

  static const List<Student> samplePresets = [
    Student(
      name: 'Alex Chen',
      email: 'alex.chen@campusverse.edu',
      rollNumber: 'CS-2023-042',
      department: 'Computer Science & Engineering',
      yearOfStudy: '3rd Year (Junior)',
      phone: '+91 98765 43210',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
    ),
    Student(
      name: 'Sophia Patel',
      email: 'sophia.patel@campusverse.edu',
      rollNumber: 'EC-2024-018',
      department: 'Electronics & Communication',
      yearOfStudy: '2nd Year (Sophomore)',
      phone: '+91 98765 12345',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
    ),
    Student(
      name: 'David Miller',
      email: 'david.miller@campusverse.edu',
      rollNumber: 'IT-2022-091',
      department: 'Information Technology',
      yearOfStudy: '4th Year (Senior)',
      phone: '+91 98765 67890',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    ),
  ];
}

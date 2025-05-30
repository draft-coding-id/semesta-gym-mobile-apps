import 'package:semesta_gym/models/courseByUserId.dart';

class User {
  int id;
  String name;
  String email;
  String role;
  String phone;
  List<String> userMemberships;
  List<CourseByUserId> courses;

  User(
    this.id,
    this.name,
    this.email,
    this.role,
    this.phone,
    this.userMemberships,
    this.courses,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['id'] as int,
        json['name'] ?? '',
        json['email'] ?? '',
        json['role'] ?? '',
        json['phone'] ?? '',
        (json['UserMemberships'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        (json['Courses'] as List<dynamic>?)
                ?.map((e) => CourseByUserId.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'userMemberships': userMemberships,
        'Courses': courses.map((course) => course.toJson()).toList(),
      };
}

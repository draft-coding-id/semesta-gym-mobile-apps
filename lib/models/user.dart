class User {
  int id;
  String name;
  String email;
  String password;
  String role;
  String phone;
  List<String> userMemberships;
  List<String> courses;

  User(
    this.id,
    this.name,
    this.email,
    this.password,
    this.role,
    this.phone,
    this.userMemberships,
    this.courses,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['id'] as int,
        json['name'] ?? '',
        json['email'] ?? '',
        json['password'] ?? '',
        json['role'] ?? '',
        json['phone'] ?? '',
        (json['userMemberships'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        (json['courses'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
        'userMemberships': userMemberships,
        'courses': courses,
      };
}

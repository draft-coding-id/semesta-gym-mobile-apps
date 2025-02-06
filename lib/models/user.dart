class User {
  String name;
  String email;
  String password;
  String role;
  String phone;

  User(
    this.name,
    this.email,
    this.password,
    this.role,
    this.phone,
  );

  factory User.fromJson(Map<String, dynamic> json) => User(
        json['name'] ?? '',
        json['email'] ?? '',
        json['password'] ?? '',
        json['role'] ?? '',
        json['phone'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
      };
}

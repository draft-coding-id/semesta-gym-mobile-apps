import 'package:semesta_gym/models/trainingFocus.dart';
import 'package:semesta_gym/models/user.dart';

class Trainer {
  int id;
  User user;
  String name;
  String email;
  String phone;
  String rating;
  List<TrainingFocus> trainingFocus;
  String description;
  String hoursOfPractice;
  int price;
  String picture;

  Trainer(
    this.id,
    this.user,
    this.name,
    this.email,
    this.phone,
    this.rating,
    this.trainingFocus,
    this.description,
    this.hoursOfPractice,
    this.price,
    this.picture,
  );

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        json['id'] ?? 0,
        User.fromJson(json['User'] ?? {}), 
        json['User']?['name'] ?? '',
        json['User']?['email'] ?? '',
        json['User']?['phone']?.toString() ?? '',
        json['rating'] ?? '',
        (json['TrainingFocus'] as List<dynamic>?)
                ?.map((e) => TrainingFocus.fromJson(e))
                .toList() ??
            [],
        json['description'] ?? '',
        json['hoursOfPractice'] ?? '',
        double.tryParse(json['price'] ?? '0.0')?.toInt() ?? 0,
        json['picture'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'name': name,
        'email': email,
        'phone': phone,
        'trainingFocus': trainingFocus.map((e) => e.toJson()).toList(),
        'description': description,
        'hoursOfPractice': hoursOfPractice,
        'price': price,
        'picture': picture,
      };
}

// paten sementera
/* class Trainer {
  int id;
  String name;
  String email;
  String phone;
  List<int> trainingFocus;
  String description;
  String hoursOfPractice;
  int price;
  String picture;

  Trainer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.trainingFocus,
    required this.description,
    required this.hoursOfPractice,
    required this.price,
    required this.picture,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: json['id'] ?? 0,
        name: json['User']?['name']?.toString() ?? '',
        email: json['User']?['email']?.toString() ?? '',
        phone: json['User']?['phone']?.toString() ?? '',
        trainingFocus: (json['TrainingFocus'] as List<dynamic>?)
                ?.map((e) => int.tryParse(e.toString()) ?? 0)
                .toList() ??
            [],
        description: json['description'] ?? '',
        hoursOfPractice: json['hoursOfPractice'] ?? '',
        price: int.tryParse(json['price'] ?? '0') ?? 0,
        picture: json['picture'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'trainingFocus': trainingFocus,
        'description': description,
        'hoursOfPractice': hoursOfPractice,
        'price': price,
        'picture': picture,
      };
} */

/* class Trainer {
  String name;
  String email;
  String password;
  String phone;
  List<int> trainingFocus;
  String description;
  String hoursOfPractice;
  int price;
  String picture;

  Trainer({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.trainingFocus,
    required this.description,
    required this.hoursOfPractice,
    required this.price,
    required this.picture,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        password: json['password'] ?? '',
        phone: json['phone'] ?? '',
        trainingFocus: List<int>.from(json['trainingFocus'] ?? []),
        description: json['description'] ?? '',
        hoursOfPractice: json['hoursOfPractice'] ?? '',
        price: json['price'] ?? 0,
        picture: json['picture'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'trainingFocus': trainingFocus,
        'description': description,
        'hoursOfPractice': hoursOfPractice,
        'price': price,
        'picture': picture,
      };
}
 */

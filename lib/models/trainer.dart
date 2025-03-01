import 'package:semesta_gym/models/review.dart';
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
  List<Review> review;

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
    this.review
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
        (json['Reviews'] as List<dynamic>?)
                ?.map((e) => Review.fromJson(e))
                .toList() ??
            [],
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
        'review': review.map((e) => e.toJson()).toList(),
      };
}

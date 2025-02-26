import 'package:semesta_gym/models/user.dart';

class Booking {
  final int id;
  final int memberId;
  final int trainerId;
  final DateTime week1Date;
  final bool week1Done;
  final DateTime week2Date;
  final bool week2Done;
  final DateTime week3Date;
  final bool week3Done;
  final DateTime week4Date;
  final bool week4Done;
  final bool acceptedTrainer;
  final bool done;
  final String? reasonRejection;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User member;
  final Trainer trainer;
  final String? endDate;

  Booking({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.week1Date,
    required this.week1Done,
    required this.week2Date,
    required this.week2Done,
    required this.week3Date,
    required this.week3Done,
    required this.week4Date,
    required this.week4Done,
    required this.acceptedTrainer,
    required this.done,
    this.reasonRejection,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.member,
    required this.trainer,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      memberId: json['memberId'],
      trainerId: json['trainerId'],
      week1Date: DateTime.parse(json['week1Date']),
      week1Done: json['week1Done'],
      week2Date: DateTime.parse(json['week2Date']),
      week2Done: json['week2Done'],
      week3Date: DateTime.parse(json['week3Date']),
      week3Done: json['week3Done'],
      week4Date: DateTime.parse(json['week4Date']),
      week4Done: json['week4Done'],
      endDate: json['endDate'] ?? '',
      acceptedTrainer: json['acceptedTrainer'],
      done: json['done'],
      reasonRejection: json['reasonRejection'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      member: User.fromJson(json['member']),
      trainer: Trainer.fromJson(json['trainer']),
    );
  }
}

class Trainer {
  int id;
  String name;
  String email;
  String phone;
  String description;
  String hoursOfPractice;
  int price;
  String picture;

  Trainer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    required this.hoursOfPractice,
    required this.price,
    required this.picture,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) => Trainer(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone']?.toString() ?? '',
        description: json['Trainer']?['description'] ?? '',
        hoursOfPractice: json['Trainer']?['hoursOfPractice'] ?? '', 
        price: double.tryParse(json['Trainer']?['price'] ?? '0.0')?.toInt() ?? 0,
        picture: json['Trainer']?['picture'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'description': description,
        'hoursOfPractice': hoursOfPractice,
        'price': price,
        'picture': picture,
      };
}



/* import 'package:semesta_gym/models/user.dart';

class Booking {
  final int id;
  final int memberId;
  final int trainerId;
  final DateTime week1Date;
  final bool week1Done;
  final DateTime week2Date;
  final bool week2Done;
  final DateTime week3Date;
  final bool week3Done;
  final DateTime week4Date;
  final bool week4Done;
  final bool acceptedTrainer;
  final bool done;
  final String? reasonRejection;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User member;
  final User trainer;

  Booking({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.week1Date,
    required this.week1Done,
    required this.week2Date,
    required this.week2Done,
    required this.week3Date,
    required this.week3Done,
    required this.week4Date,
    required this.week4Done,
    required this.acceptedTrainer,
    required this.done,
    this.reasonRejection,
    required this.createdAt,
    required this.updatedAt,
    required this.member,
    required this.trainer,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      memberId: json['memberId'],
      trainerId: json['trainerId'],
      week1Date: DateTime.parse(json['week1Date']),
      week1Done: json['week1Done'],
      week2Date: DateTime.parse(json['week2Date']),
      week2Done: json['week2Done'],
      week3Date: DateTime.parse(json['week3Date']),
      week3Done: json['week3Done'],
      week4Date: DateTime.parse(json['week4Date']),
      week4Done: json['week4Done'],
      acceptedTrainer: json['acceptedTrainer'],
      done: json['done'],
      reasonRejection: json['reasonRejection'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      member: User.fromJson(json['member']),
      trainer: User.fromJson(json['trainer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'trainerId': trainerId,
      'week1Date': week1Date.toIso8601String(),
      'week1Done': week1Done,
      'week2Date': week2Date.toIso8601String(),
      'week2Done': week2Done,
      'week3Date': week3Date.toIso8601String(),
      'week3Done': week3Done,
      'week4Date': week4Date.toIso8601String(),
      'week4Done': week4Done,
      'acceptedTrainer': acceptedTrainer,
      'done': done,
      'reasonRejection': reasonRejection,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'member': member.toJson(),
      'trainer': trainer.toJson(),
    };
  }
}
 */
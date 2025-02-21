import 'package:semesta_gym/models/trainingFocus.dart';

class Course {
  final int id;
  final int trainingFocusId;
  final String name;
  final String description;
  final int numberOfPractices;
  final String picture;
  TrainingFocus trainingFocus;

  Course({
    required this.id,
    required this.trainingFocusId,
    required this.name,
    required this.description,
    required this.numberOfPractices,
    required this.picture,
    required this.trainingFocus,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      trainingFocusId: json['trainingFocusId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      numberOfPractices: json['numberOfPractices'] ?? 0,
      picture: json['picture'],
      trainingFocus: TrainingFocus.fromJson(json['User'] ?? {}), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingFocusId': trainingFocusId,
      'name': name,
      'description': description,
      'numberOfPractices': numberOfPractices,
      'picture': picture,
      'TrainingFocu': trainingFocus.toJson(),
    };
  }
}

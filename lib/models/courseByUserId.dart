
class CourseByUserId {
  int id;
  int userId;
  String price;
  String startDate;
  String endDate;

  CourseByUserId({
    required this.id,
    required this.userId,
    required this.price,
    required this.startDate,
    required this.endDate,
  });

  factory CourseByUserId.fromJson(Map<String, dynamic> json) {
    return CourseByUserId(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      price: json['price'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'price': price,
        'startDate': startDate,
        'endDate': endDate
      };
}

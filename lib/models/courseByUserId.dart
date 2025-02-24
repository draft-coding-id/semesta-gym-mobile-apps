
class CourseByUserId {
  int id;
  int userId;
  String price;
  String startDate;
  String endDate;

  CourseByUserId(
     this.id,
     this.userId,
     this.price,
     this.startDate,
     this.endDate,
  );

  factory CourseByUserId.fromJson(Map<String, dynamic> json) {
    return CourseByUserId(
      json['id'] ?? 0,
      json['userId'] ?? 0,
      json['price'] ?? '',
      json['startDate'] ?? '',
      json['endDate'] ?? '',
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

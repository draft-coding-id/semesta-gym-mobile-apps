class Review {
  int? id;
  int? memberId;
  int? trainerId;
  int? bookingId;
  int? rating;
  String? comment;

  Review({
    this.id,
    this.memberId,
    this.trainerId,
    this.bookingId,
    this.rating,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      memberId: json['memberId'] ?? 0,
      trainerId: json['trainerId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'trainerId': trainerId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
    };
  }
}

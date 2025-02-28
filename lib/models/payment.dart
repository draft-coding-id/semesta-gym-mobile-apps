class Payment {
  int id;
  int paymentableId;
  String paymentableType;
  String title;
  String amount;
  String paymentStatus;
  String paidAt;
  int userId;
  User user;

  Payment(
    this.id,
    this.paymentableId,
    this.paymentableType,
    this.title,
    this.amount,
    this.paymentStatus,
    this.paidAt,
    this.userId,
    this.user,
  );

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      json['id'] ?? 0,
      json['paymentableId'] ?? 0,
      json['paymentableType'] ?? '',
      json['title'] ?? '',
      json['amount'] ?? '',
      json['paymentStatus'] ?? '',
      json['paidAt'] ?? '',
      json['userId'] ?? 0,
      json['user'] != null ? User.fromJson(json['user']) : User('Unknown'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentableId': paymentableId,
      'paymentableType': paymentableType,
      'title': title,
      'amount': amount,
      'paymentStatus': paymentStatus,
      'paidAt': paidAt,
      'userId': userId,
      'User': user.toJson(),
    };
  }
}

class User {
  String name;

  User(this.name);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['name'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

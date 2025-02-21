class Membership {
  final int id;
  final String name;
  final double price;
  final String description;

  Membership({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price']),
      description: json['description'],
    );
  }
}

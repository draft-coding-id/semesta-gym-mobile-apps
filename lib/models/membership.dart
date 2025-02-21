class Membership {
  final int id;
  final String name;
  final double price;
  final int duration;
  final String description;

  Membership({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.parse(json['price']) ?? 0,
      duration: json['duration'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

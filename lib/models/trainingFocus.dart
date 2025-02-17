class TrainingFocus {
  int id;
  String name;
  String picture;

  TrainingFocus(this.id, this.name, this.picture);

  factory TrainingFocus.fromJson(Map<String, dynamic> json) => TrainingFocus(
        json['id'] ?? 0,
        json['name'] ?? '',
        json['picture'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'picture': picture,
      };
}
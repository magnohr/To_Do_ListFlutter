class TodoModel {
  final String title;
  final String description;
  final DateTime? date;
  final String? imagePath;

  TodoModel({
    required this.title,
    required this.description,
    this.date,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'date': date?.toIso8601String(),
    'imagePath': imagePath,
  };

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      title: json['title'],
      description: json['description'],
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : null,
      imagePath: json['imagePath'],
    );
  }
}

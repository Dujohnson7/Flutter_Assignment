class Todo {
  String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;

  Todo({
    required this.title,
    this.description,
    this.isCompleted = false,
    String? id,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();
}
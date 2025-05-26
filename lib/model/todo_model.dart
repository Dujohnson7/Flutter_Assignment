class Todo {
  String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;
  String category;
  DateTime? dueDate;

  Todo({
    required this.title,
    this.description,
    this.isCompleted = false,
    this.category = 'Personal',
    this.dueDate,
    String? id,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now();

  Todo.update({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    this.category = 'Personal',
    this.dueDate,
  });
}
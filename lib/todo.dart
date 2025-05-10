
class Todo {
  final String id;
  final String title;
  final String descr;
  bool completed;

  Todo({required this.id, required this.title, required this.descr,  this.completed = false});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      descr: json['descr'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descr': descr,
      'completed': completed,
    };
  }
}
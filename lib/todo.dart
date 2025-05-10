
class Todo {
  final String id;
  final String title;
  final String descr;

  Todo({required this.id, required this.title, required this.descr});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      descr: json['descr'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descr': descr,
    };
  }
}
class Todo {
  final String id;
  final String title;
  final String descr;
  bool completed;
  final DateTime createdAt; // 新增字段

  Todo({
    required this.id,
    required this.title,
    required this.descr,
    this.completed = false,
    DateTime? createdAt, // 可选参数
  }) : createdAt = createdAt ?? DateTime.now(); // 如果未提供 createdAt，则默认为当前时间

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      descr: json['descr'],
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()), // 从 JSON 解析日期
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descr': descr,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(), // 将日期转换为 ISO 格式
    };
  }
}
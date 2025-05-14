class Todo {
  final String id;
  final String title;
  final String descr;
  bool completed;
  final DateTime createdAt;
  DateTime? notificationTime; // 新增：通知时间字段
  DateTime? nextNotificationTime; // 新增：下次通知时间字段

  Todo({
    required this.id,
    required this.title,
    required this.descr,
    this.completed = false,
    DateTime? createdAt,
    this.notificationTime, // 新增可选参数
    this.nextNotificationTime,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      descr: json['descr'],
      completed: json['completed'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      notificationTime: json['notificationTime'] != null 
          ? DateTime.parse(json['notificationTime']) 
          : null, // 新增反序列化
      nextNotificationTime: json['nextNotificationTime'] != null
          ? DateTime.parse(json['nextNotificationTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'descr': descr,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'notificationTime': notificationTime?.toIso8601String(), // 新增序列化
      'nextNotificationTime': nextNotificationTime?.toIso8601String(),
    };
  }
}
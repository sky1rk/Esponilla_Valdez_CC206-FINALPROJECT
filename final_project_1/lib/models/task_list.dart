class TaskList {
  final String id;
  final String name;
  final int level;

  TaskList({required this.id, required this.name, required this.level});

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
    );
  }
}

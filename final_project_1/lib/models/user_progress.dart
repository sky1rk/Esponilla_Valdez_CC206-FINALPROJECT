class UserProgress {
  final String id;
  final String userId;
  int tasksCreated;
  int tasksDone;
  String? lastTaskTitle;
  DateTime? lastTaskCompletionTime;
  List<Map<String, dynamic>> completedTasks;

  UserProgress({
    required this.id,
    required this.userId,
    required this.tasksCreated,
    required this.tasksDone,
    this.lastTaskTitle,
    this.lastTaskCompletionTime,
    this.completedTasks = const [],
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tasksCreated: json['tasksCreated'] as int,
      tasksDone: json['tasksDone'] as int,
      lastTaskTitle: json['lastTaskTitle'] as String?,
      lastTaskCompletionTime: json['lastTaskCompletionTime'] != null
          ? DateTime.parse(json['lastTaskCompletionTime'] as String)
          : null,
      completedTasks: json['completedTasks'] != null
          ? List<Map<String, dynamic>>.from(json['completedTasks'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'tasksCreated': tasksCreated,
        'tasksDone': tasksDone,
        'lastTaskTitle': lastTaskTitle,
        'lastTaskCompletionTime': lastTaskCompletionTime?.toIso8601String(),
        'completedTasks': completedTasks,
      };
}

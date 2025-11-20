class Task {
  final String? id;
  final String? taskListId;
  final String title;
  final DateTime? dateTime;
  final String? notes;
  final String? username;
  final bool isCompleted;

  Task({
    this.id,
    this.taskListId,
    required this.title,
    this.dateTime,
    this.notes,
    this.username,
    this.isCompleted = false,
  });

  static final List<Task> _temporarilyCompleted = [];

  static void addToTempCache(Task task) {
    _temporarilyCompleted.add(task);
  }

  static List<Task> getTempCache() {
    return List.from(_temporarilyCompleted);
  }

  static void clearTempCache() {
    _temporarilyCompleted.clear();
  }

  static bool isInTempCache(String taskId) {
    return _temporarilyCompleted.any((task) => task.id == taskId);
  }
}

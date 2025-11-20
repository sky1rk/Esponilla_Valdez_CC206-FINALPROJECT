import '../models/task.dart';

/// Simple in-memory Task repository for the running app session.
class TaskRepository {
  TaskRepository._privateConstructor();
  static final TaskRepository instance = TaskRepository._privateConstructor();

  final List<Task> _tasks = [];

  List<Task> getAll() => List.unmodifiable(_tasks);

  void add(Task t) => _tasks.add(t);

  bool hasTasks() => _tasks.isNotEmpty;

  void clear() => _tasks.clear();
}

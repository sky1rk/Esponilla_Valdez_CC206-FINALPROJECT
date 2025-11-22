import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'main_forest.dart';
import 'profile_screen_forest.dart';
import 'new_task_forest.dart';
import 'progress_screen_forest.dart';

class TasksScreen extends StatefulWidget {
  final String username;
  const TasksScreen({super.key, required this.username});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final serverTasks = await apiService.fetchTasks(
        username: widget.username,
      );
      final filteredTasks = serverTasks
          .where((t) => !Task.isInTempCache(t.id!))
          .toList();
      filteredTasks.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
      setState(() => _tasks = filteredTasks);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    final success = await apiService.deleteTask(taskId);
    if (success) {
      _loadTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete task on server.')),
      );
    }
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    final groupedTasks = <DateTime, List<Task>>{};
    for (final task in tasks) {
      final date = DateTime(
        task.dateTime!.year,
        task.dateTime!.month,
        task.dateTime!.day,
      );
      groupedTasks.putIfAbsent(date, () => []);
      groupedTasks[date]!.add(task);
    }
    return groupedTasks;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTasks = _groupTasksByDate(_tasks);
    final sortedDates = groupedTasks.keys.toList()..sort();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/forest.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: NotivaColors.gold,
                        ),
                        label: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 20,
                            color: NotivaColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(username: widget.username),
                            ),
                          );
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NotivaColors.panelBorder,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/witch.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    'MyTasks',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: NotivaColors.gold,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 3),
                          blurRadius: 8,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: NotivaColors.gold,
                            ),
                          )
                        : groupedTasks.isEmpty
                        ? Center(
                            child: Text(
                              'No tasks yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              final date = sortedDates[index];
                              final tasks = groupedTasks[date]!;
                              final formattedDate = DateFormat(
                                'EEEE, MMMM d, y',
                              ).format(date);

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: NotivaColors.panel.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: NotivaColors.panelBorder,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: NotivaColors.shadow,
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          color: NotivaColors.gold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      children: tasks.map((task) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: NotivaColors.panel
                                                .withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: NotivaColors.panelBorder
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                DateFormat(
                                                  'h:mm a',
                                                ).format(task.dateTime!),
                                                style: const TextStyle(
                                                  color: Color(0xFFFFF8E1),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  task.title,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: NotivaColors.gold,
                                                ),
                                                onPressed: () async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          NewTaskScreen(
                                                            username:
                                                                widget.username,
                                                            task: task,
                                                          ),
                                                    ),
                                                  );
                                                  _loadTasks();
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: NotivaColors.gold,
                                                ),
                                                onPressed: () =>
                                                    _deleteTask(task.id!),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 10),
                  _buildMainButton(
                    text: 'Add Task',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NewTaskScreen(username: widget.username),
                        ),
                      );
                      _loadTasks();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildMainButton(
                    text: 'View Task Progress',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProgressScreen(username: widget.username),
                        ),
                      );
                      _loadTasks();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          shadowColor: NotivaColors.shadow,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [NotivaColors.buttonTop, NotivaColors.buttonBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFF8E1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

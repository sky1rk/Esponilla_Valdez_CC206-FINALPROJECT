import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/completed_task.dart';
import '../services/api_service.dart';
import 'main_forest.dart';
import 'profile_screen_forest.dart';

class HistoryScreen extends StatefulWidget {
  final String username;

  const HistoryScreen({super.key, required this.username});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<CompletedTask>> _completedTasksFuture;

  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks();
  }

  void _fetchCompletedTasks() {
    setState(() {
      _completedTasksFuture = apiService.fetchCompletedTasks(widget.username);
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all completed tasks?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await apiService.clearHistory(widget.username);
      if (success) {
        _fetchCompletedTasks();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to clear history.')),
        );
      }
    }
  }

  Map<DateTime, List<CompletedTask>> _groupTasksByDate(
    List<CompletedTask> tasks,
  ) {
    final groupedTasks = <DateTime, List<CompletedTask>>{};
    for (final task in tasks) {
      final date = DateTime(
        task.completionDate.year,
        task.completionDate.month,
        task.completionDate.day,
      );
      groupedTasks.putIfAbsent(date, () => []);
      groupedTasks[date]!.add(task);
    }
    return groupedTasks;
  }

  @override
  Widget build(BuildContext context) {
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
                  Center(
                    child: Text(
                      'History',
                      style: const TextStyle(
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
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _clearHistory,
                      icon: const Icon(
                        Icons.delete_sweep,
                        color: NotivaColors.gold,
                        size: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<CompletedTask>>(
                      future: _completedTasksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: NotivaColors.gold,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No completed tasks yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final groupedTasks = _groupTasksByDate(snapshot.data!);
                        final sortedDates = groupedTasks.keys.toList()
                          ..sort((a, b) => b.compareTo(a));

                        return ListView.builder(
                          itemCount: sortedDates.length,
                          itemBuilder: (context, index) {
                            final date = sortedDates[index];
                            final tasks = groupedTasks[date]!;
                            final formattedDate = DateFormat(
                              'EEEE, MMMM d, y',
                            ).format(date);

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
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
                                          color: NotivaColors.panel.withOpacity(
                                            0.85,
                                          ),
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
                                              ).format(task.completionDate),
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
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

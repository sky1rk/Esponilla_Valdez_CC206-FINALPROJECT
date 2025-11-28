import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main_forest.dart';
import 'profile_screen_forest.dart';
import 'new_task_forest.dart';
import 'tasks_screen_forest.dart';
import 'rewards_screen_forest.dart';
import 'history_screen_forest.dart';
import '../services/task_repository.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Task? _nextTask;
  bool _hasTasks = false;
  bool _isRewardsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    List<Task> tasks = [];
    try {
      tasks = await apiService.fetchTasks(username: widget.username);
    } catch (_) {
      tasks = TaskRepository.instance.getAll();
    }

    final userTasks = tasks
        .where(
          (t) =>
              t.username == widget.username &&
              !t.isCompleted &&
              !Task.isInTempCache(t.id!),
        )
        .toList();

    if (userTasks.isNotEmpty) {
      userTasks.sort((a, b) {
        final aDt = a.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDt = b.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDt.compareTo(bDt);
      });
      if (mounted) {
        setState(() {
          _nextTask = userTasks.first;
          _hasTasks = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _nextTask = null;
          _hasTasks = false;
        });
      }
    }
  }

  Future<void> _onViewRewardsPressed() async {
    setState(() {
      _isRewardsLoading = true;
    });

    try {
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RewardsScreen(username: widget.username),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load rewards: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRewardsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEE, MMM d, y').format(now);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/forest.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const avatarReserve = 140;
                          final maxTextWidth =
                              (constraints.maxWidth - avatarReserve).clamp(
                                60.0,
                                constraints.maxWidth,
                              );
                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxTextWidth,
                              ),
                              child: Text(
                                'Hello, ${widget.username}!',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 47,
                                  fontWeight: FontWeight.w900,
                                  color: NotivaColors.gold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                      color: NotivaColors.shadow,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Semantics(
                          label: 'Profile picture, tap to open profile',
                          button: true,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
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
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: NotivaColors.panel.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: NotivaColors.panelBorder,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NotivaColors.shadow,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NotivaColors.gold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 14),

                      DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: NotivaColors.shadow,
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              NotivaColors.buttonTop,
                              NotivaColors.buttonBottom,
                            ],
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NewTaskScreen(username: widget.username),
                                ),
                              );
                              await _loadPreview();
                            },
                            child: const Text(
                              'Add New Task',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 248, 225),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: NotivaColors.panel.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: NotivaColors.panelBorder,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NotivaColors.shadow,
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Upcoming Deadlines',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: NotivaColors.gold,
                            ),
                          ),
                          Semantics(
                            label: 'Task history, tap to open history screen',
                            button: true,
                            child: IconButton(
                              icon: const Icon(
                                Icons.history,
                                color: NotivaColors.gold,
                              ),
                              iconSize: 30,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryScreen(
                                      username: widget.username,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_nextTask == null)
                        const Text(
                          'No tasks yet!',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nextTask!.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 249, 240, 240),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_nextTask!.dateTime != null) ...[
                              Text(
                                DateFormat(
                                  'EEE, MMM d, y',
                                ).format(_nextTask!.dateTime!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat(
                                  'hh:mm a',
                                ).format(_nextTask!.dateTime!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                          ],
                        ),
                      const SizedBox(height: 14),

                      DecoratedBox(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: NotivaColors.shadow,
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                          ],
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              NotivaColors.buttonTop,
                              NotivaColors.buttonBottom,
                            ],
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _hasTasks
                                ? () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TasksScreen(
                                          username: widget.username,
                                        ),
                                      ),
                                    );
                                    await _loadPreview();
                                  }
                                : null,
                            child: Text(
                              'View Tasks',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _hasTasks
                                    ? const Color.fromARGB(255, 255, 248, 225)
                                    : Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DecoratedBox(
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: NotivaColors.shadow,
                        offset: Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        NotivaColors.buttonTop,
                        NotivaColors.buttonBottom,
                      ],
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RewardsScreen(username: widget.username),
                          ),
                        );
                      },
                      child: const Text(
                        'View Rewards',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 248, 225),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

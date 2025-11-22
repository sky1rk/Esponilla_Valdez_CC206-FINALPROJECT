import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/user_progress.dart';
import 'main_winter.dart';
import 'profile_screen_winter.dart';
import 'rewards_screen_winter.dart';
import '../services/api_service.dart';

class ProgressScreen1 extends StatefulWidget {
  final String username;
  const ProgressScreen1({super.key, required this.username});

  @override
  State<ProgressScreen1> createState() => _ProgressScreen1State();
}

class _ProgressScreen1State extends State<ProgressScreen1> {
  UserProgress? _userProgress;
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isClaiming = false;

  int _currentLevel = 1;
  int _tasksDoneInCurrentLevel = 0;
  int _tasksRequiredForLevel = 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _calculateLevelStats(int totalTasksDone) {
    int level = 1;
    int tasksForLevel = 5;
    int cumulativeTasks = 0;

    while (totalTasksDone >= cumulativeTasks + tasksForLevel) {
      cumulativeTasks += tasksForLevel;
      level++;
      tasksForLevel += 2;
    }

    _currentLevel = level;
    _tasksRequiredForLevel = tasksForLevel;
    _tasksDoneInCurrentLevel = totalTasksDone - cumulativeTasks;
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await apiService.getUserByUsername(widget.username);
      if (user == null || user['id'] == null) throw Exception('User not found');

      final progress = await apiService.fetchUserProgress(user['id'] as String);
      final tasks = await apiService.fetchTasks(username: widget.username);

      setState(() {
        if (progress != null) {
          _userProgress = progress;
        } else {
          _userProgress = UserProgress(
            id: 'new_progress',
            userId: user['id'] as String,
            tasksCreated: 0,
            tasksDone: 0,
            completedTasks: <Map<String, dynamic>>[],
          );
        }

        _tasks = tasks.where((t) => !t.isCompleted && !Task.isInTempCache(t.id!)).toList();
        _calculateLevelStats(_userProgress!.tasksDone);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  void _onTaskCheckedChanged(Task task, bool? isChecked) {
    setState(() {
      if (isChecked == true) {
        Task.addToTempCache(task);
        _tasks.removeWhere((t) => t.id == task.id);
      }
    });
  }

  Future<void> _claimReward() async {
    final tempTasks = Task.getTempCache();
    if (_userProgress == null || tempTasks.isEmpty || _isClaiming) return;

    setState(() => _isClaiming = true);

    final originalTasksDone = _userProgress!.tasksDone;
    final originalCompletedTasks = List<Map<String, dynamic>>.from(_userProgress!.completedTasks);

    try {
      _userProgress!.tasksDone += tempTasks.length;
      _userProgress!.lastTaskTitle = tempTasks.last.title;
      _userProgress!.lastTaskCompletionTime = DateTime.now();
      final newHistoryItems = tempTasks.map((task) => {
        'title': task.title,
        'completionDate': DateTime.now().toIso8601String(),
      }).toList();
      _userProgress!.completedTasks.addAll(newHistoryItems);

      final success = await apiService.updateUserProgress(_userProgress!);

      if (success) {
        await apiService.deleteTasks(tempTasks.map((t) => t.id!).toList());
        Task.clearTempCache();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward claimed and progress saved!')));
          _calculateLevelStats(_userProgress!.tasksDone);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RewardsScreen1(username: widget.username),
            ),
          ).then((_) => _loadData());
        }
      } else {
        throw Exception('Server update failed.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to claim reward. Please try again.')));
        setState(() {
          _userProgress!.tasksDone = originalTasksDone;
          _userProgress!.completedTasks = originalCompletedTasks;
          _tasks.addAll(Task.getTempCache());
          _tasks.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
          Task.clearTempCache();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: NotivaColors.panelBorder)),
      );
    }

    final progressForCurrentLevel = _tasksDoneInCurrentLevel + Task.getTempCache().length;
    final isClaimable = progressForCurrentLevel >= _tasksRequiredForLevel;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/winter.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildTitle(),
                  const SizedBox(height: 20),
                  _buildProgressCard(progressForCurrentLevel, isClaimable),
                  const SizedBox(height: 10),
                  _buildTaskListCard(),
                  const SizedBox(height: 14),
                  _buildGradientButton(
                    text: _isClaiming ? 'Claiming...' : 'Claim Reward',
                    onPressed: (isClaimable && !_isClaiming) ? _claimReward : null,
                  ),
                  const SizedBox(height: 10),
                  _buildGradientButton(
                    text: 'View Rewards',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RewardsScreen1(username: widget.username)),
                      );
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: NotivaColors.panelBorder),
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back', style: TextStyle(fontSize: 23)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen1(username: widget.username)),
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: NotivaColors.panelBorder, width: 3),
            ),
            child: ClipOval(child: Image.asset('assets/images/witch1.png', fit: BoxFit.cover)),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Task Progress',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: NotivaColors.glacial,
        shadows: [BoxShadow(offset: const Offset(0, 2), blurRadius: 6, color: NotivaColors.shadow)],
      ),
    );
  }

  Widget _buildProgressCard(int currentProgress, bool isLevelComplete) {
    return Card(
      color: NotivaColors.panel.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: NotivaColors.panelBorder, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: isLevelComplete ? Colors.greenAccent : NotivaColors.buttonBottom, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Complete tasks to claim reward',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isLevelComplete ? Colors.greenAccent : NotivaColors.bgTop),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$currentProgress/$_tasksRequiredForLevel',
                  style: const TextStyle(
                    color: NotivaColors.bgTop,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _tasksRequiredForLevel == 0 ? 0 : currentProgress / _tasksRequiredForLevel,
                    backgroundColor: NotivaColors.buttonTop,
                    valueColor: AlwaysStoppedAnimation<Color>(isLevelComplete ? Colors.greenAccent : NotivaColors.glacial),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.card_giftcard, color: NotivaColors.buttonBottom, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListCard() {
    return Expanded(
      child: Card(
        color: NotivaColors.panel.withOpacity(0.8),
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: NotivaColors.panelBorder, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete tasks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: NotivaColors.bgTop),
              ),
              const Divider(color: NotivaColors.bgTop, thickness: 1, height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Row(
                      children: [
                        Checkbox(
                          value: false,
                          onChanged: (bool? value) => _onTaskCheckedChanged(task, value),
                          activeColor: Colors.greenAccent,
                          checkColor: Colors.white,
                          side: const BorderSide(color: NotivaColors.panelBorder, width: 2),
                        ),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(color: NotivaColors.bgTop),
                          ),
                        ),
                        Text(
                          DateFormat('hh:mm a').format(task.dateTime!),
                          style: const TextStyle(color: NotivaColors.bgBottom),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback? onPressed}) {
    final isEnabled = onPressed != null;
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        gradient: LinearGradient(
          colors: isEnabled
              ? [NotivaColors.buttonTop, NotivaColors.buttonBottom]
              : [Colors.grey[800]!, Colors.grey[700]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        shadows: [BoxShadow(color: NotivaColors.shadow, offset: const Offset(0, 6), blurRadius: 12)],
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isEnabled
                  ? Colors.white
                  : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}

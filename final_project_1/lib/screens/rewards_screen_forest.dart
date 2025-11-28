import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/api_service.dart';
import 'main_forest.dart';
import 'profile_screen_forest.dart';
import 'rewards_screen_winter.dart';
import 'homescreen_winter.dart';

class RewardsScreen extends StatefulWidget {
  final String username;

  const RewardsScreen({super.key, required this.username});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String _selectedCharacter = 'assets/images/toddler.png';
  String _selectedTheme = 'assets/images/forest.jpg';
  int _tasksDone = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserProgress();
  }

  Future<void> _fetchUserProgress() async {
    final user = await apiService.getUserByUsername(widget.username);
    if (user != null) {
      final userId = user['id'] as String;
      final progress = await apiService.fetchUserProgress(userId);
      if (progress != null) {
        setState(() {
          _tasksDone = progress.tasksDone;
          _updateCharacter();
        });
      }
    }
  }

  void _updateCharacter() {
    if (_tasksDone >= 12) {
      _selectedCharacter = 'assets/images/adult.png';
    } else if (_tasksDone >= 5) {
      _selectedCharacter = 'assets/images/teen.png';
    }
  }

  void _onCharacterTap(String imagePath, bool isUnlocked) {
    if (isUnlocked) {
      setState(() {
        _selectedCharacter = imagePath;
      });
    }
  }

  void _onThemeTap(String imagePath, bool isUnlocked) {
    if (isUnlocked) {
      setState(() {
        _selectedTheme = imagePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_selectedTheme, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.25)),
          SafeArea(
            child: SingleChildScrollView(
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
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Image.asset(
                          _selectedCharacter,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
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
                          'Character Growth',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: NotivaColors.gold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRewardItem(
                              'assets/images/toddler1.png',
                              isUnlocked: true,
                              isSelected:
                                  _selectedCharacter ==
                                  'assets/images/toddler.png',
                              onTap: () => _onCharacterTap(
                                'assets/images/toddler.png',
                                true,
                              ),
                            ),
                            _buildRewardItem(
                              'assets/images/teen1.png',
                              isUnlocked: _tasksDone >= 5,
                              isSelected:
                                  _selectedCharacter ==
                                  'assets/images/teen.png',
                              onTap: () => _onCharacterTap(
                                'assets/images/teen.png',
                                _tasksDone >= 5,
                              ),
                            ),
                            _buildRewardItem(
                              'assets/images/adult1.png',
                              isUnlocked: _tasksDone >= 12,
                              isSelected:
                                  _selectedCharacter ==
                                  'assets/images/adult.png',
                              onTap: () => _onCharacterTap(
                                'assets/images/adult.png',
                                _tasksDone >= 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Themes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: NotivaColors.gold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRewardItem(
                              'assets/images/forest.jpg',
                              isUnlocked: true,
                              isSelected:
                                  _selectedTheme == 'assets/images/forest.jpg',
                              onTap: () {
                                if (_tasksDone >= 5) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RewardsScreen(
                                        username: widget.username,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            _buildRewardItem(
                              'assets/images/winter.png',
                              isUnlocked: _tasksDone >= 5,
                              isSelected:
                                  _selectedTheme == 'assets/images/winter.png',
                              onTap: () {
                                if (_tasksDone >= 5) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen1(
                                        username: widget.username,
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                            _buildRewardItem(
                              'assets/images/spring.png',
                              isUnlocked: _tasksDone >= 12,
                              isSelected:
                                  _selectedTheme == 'assets/images/spring.png',
                              onTap: () => _onThemeTap(
                                'assets/images/spring.png',
                                _tasksDone >= 12,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildRewardItem(
    String? imagePath, {
    bool isUnlocked = false,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: NotivaColors.panel.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? NotivaColors.gold : NotivaColors.panelBorder,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: NotivaColors.gold, size: 40),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

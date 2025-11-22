import 'package:flutter/material.dart';
import 'main_forest.dart';
import 'edit_profile_forest.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await apiService.getUserByUsername(widget.username);
    if (!mounted) return;
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await apiService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/forest.jpg', fit: BoxFit.cover),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: NotivaColors.gold,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back', style: TextStyle(fontSize: 23)),
                  ),
                ),

                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else
                  Align(
                    alignment: const Alignment(0, -0.6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w800,
                              color: NotivaColors.gold,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: NotivaColors.shadow,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: 120,
                            height: 120,
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
                          const SizedBox(height: 18),
                          _DisplayContainer(
                            icon: Icons.person_rounded,
                            label: 'Username',
                            value:
                                _user?['username'] as String? ??
                                widget.username,
                          ),
                          const SizedBox(height: 12),
                          _DisplayContainer(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            value: _user?['email'] as String? ?? '',
                          ),
                          const SizedBox(height: 12),
                          _DisplayContainer(
                            icon: Icons.lock_rounded,
                            label: 'Password',
                            value: (_user?['password'] as String? ?? '').isEmpty
                                ? '••••••••'
                                : '••••••••',
                          ),

                          const SizedBox(height: 18),
                          DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
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
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: () async {
                                  final res = await Navigator.push<String?>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProfileScreen(
                                        username: widget.username,
                                      ),
                                    ),
                                  );
                                  if (res != null && res.isNotEmpty) {
                                    final u = await apiService
                                        .getUserByUsername(res);
                                    if (!mounted) return;
                                    setState(() => _user = u);
                                  }
                                },
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromARGB(255, 255, 248, 225),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
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
                                colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                onPressed: _logout,
                                child: const Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisplayContainer extends StatelessWidget {
  const _DisplayContainer({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: NotivaColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: NotivaColors.panelBorder, width: 3),
        ),
        shadows: const [
          BoxShadow(
            color: NotivaColors.shadow,
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: NotivaColors.gold, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFCBE5D7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

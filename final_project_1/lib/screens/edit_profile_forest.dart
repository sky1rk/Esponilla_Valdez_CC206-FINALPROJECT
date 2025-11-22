import 'package:flutter/material.dart';
import 'main_forest.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  const EditProfileScreen({super.key, required this.username});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await apiService.getUserByUsername(widget.username);
    if (u != null) {
      _user.text = (u['username'] ?? '') as String;
      _email.text = (u['email'] ?? '') as String;
      _pass.text = (u['password'] ?? '') as String;
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final newUsername = _user.text.trim();
    final email = _email.text.trim();
    final password = _pass.text;

    final ok = await apiService.updateUserByUsername(
      widget.username,
      newUsername: newUsername,
      email: email,
      password: password,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context, newUsername);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  void dispose() {
    _user.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
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
                    onPressed: () => Navigator.pop(context),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Edit Profile',
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
                            const SizedBox(height: 20),

                            _EditableDisplayContainer(
                              controller: _user,
                              icon: Icons.person_rounded,
                              label: 'Username',
                              hint: 'Username',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter username'
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            _EditableDisplayContainer(
                              controller: _email,
                              icon: Icons.email_rounded,
                              label: 'Email',
                              hint: 'Email Address',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Enter email address';
                                final emailRegex = RegExp(
                                  r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                                );
                                if (!emailRegex.hasMatch(v.trim()))
                                  return 'Enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            _EditableDisplayContainer(
                              controller: _pass,
                              icon: Icons.lock_rounded,
                              label: 'Password',
                              hint: 'Password',
                              obscure: _obscure,
                              suffix: SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints.tight(
                                    const Size(36, 36),
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: NotivaColors.gold,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter password'
                                  : null,
                            ),

                            const SizedBox(height: 22),

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
                                  onPressed: _save,
                                  child: const Text(
                                    'Update Profile',
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
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableDisplayContainer extends StatelessWidget {
  const _EditableDisplayContainer({
    Key? key,
    required this.controller,
    required this.icon,
    required this.label,
    required this.hint,
    this.validator,
    this.obscure = false,
    this.suffix,
  }) : super(key: key);

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final bool obscure;
  final Widget? suffix;

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: NotivaColors.gold, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFCBE5D7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: controller,
                    validator: validator,
                    obscureText: obscure,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFFCBE5D7),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 8),
              Center(child: suffix),
            ],
          ],
        ),
      ),
    );
  }
}

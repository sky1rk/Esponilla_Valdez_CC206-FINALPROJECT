import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'homescreen_winter.dart';

const String _apiBase = 'http://10.0.2.2:3000';
final ApiService apiService = ApiService(baseUrl: _apiBase);

void main() => runApp(const NotivaApp1());

class NotivaApp1 extends StatelessWidget {
  const NotivaApp1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false, fontFamily: 'Roboto'),
      home: const WelcomeScreen1(),
    );
  }
}

class NotivaColors {
  static const bgTop = Color(0xFF002B45);
  static const bgBottom = Color(0xFF1A3E5D);
  static const panel = Color(0xFFEAF6F9);
  static const panelBorder = Color(0xFF4169E1);
  static const glacial = Color(0xFF4169E1);
  static const buttonTop = Color(0xFFA9CDEB);
  static const buttonBottom = Color(0xFF7FB8D9);
  static const shadow = Color(0x554B5A6A);
}

class WelcomeScreen1 extends StatelessWidget {
  const WelcomeScreen1({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/winter.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Flexible(
                flex: 4,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 600,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: NotivaColors.glacial,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'NOTIVA',
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.w800,
                  color: NotivaColors.glacial,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 6,
                      color: NotivaColors.shadow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Turn your tasks into adventures.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    _NotivaButton1(
                      label: 'Login',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen1(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _NotivaButton1(
                      label: 'Sign Up',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen1(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen1 extends StatefulWidget {
  const LoginScreen1({super.key});

  @override
  State<LoginScreen1> createState() => _LoginScreen1State();
}

class _LoginScreen1State extends State<LoginScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/winter.png', fit: BoxFit.cover),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: NotivaColors.glacial,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen1(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back', style: TextStyle(fontSize: 23)),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.7),
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
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w800,
                              color: NotivaColors.glacial,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: NotivaColors.shadow,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _FancyField1(
                            controller: _user,
                            hint: 'Username',
                            icon: Icons.person_rounded,
                            obscure: false,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter username'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FancyField1(
                            controller: _pass,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            obscure: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Enter password'
                                : null,
                          ),
                          const SizedBox(height: 22),
                          _NotivaButton1(
                            label: 'Login',
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final username = _user.text.trim();
                                final password = _pass.text;

                                final success = await apiService.login(
                                  username,
                                  password,
                                );

                                if (success) {
                                  if (!mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen1(username: username),
                                    ),
                                  );
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invalid username or password',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen1(),
                                ),
                              );

                              _formKey.currentState?.reset();
                              _user.clear();
                              _pass.clear();
                            },
                            child: const Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                color: NotivaColors.glacial,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
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

class _FancyField1 extends StatelessWidget {
  const _FancyField1({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.obscure = false,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: NotivaColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NotivaColors.panelBorder, width: 3),
        ),
        shadows: const [
          BoxShadow(
            color: NotivaColors.shadow,
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscure,
          style: const TextStyle(
            color: NotivaColors.bgTop,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            icon: Icon(icon, color: NotivaColors.buttonBottom),
            hintText: hint,
            hintStyle: const TextStyle(
              color: NotivaColors.bgBottom,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            errorStyle: const TextStyle(
              fontSize: 18,
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            border: InputBorder.none,
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: NotivaColors.buttonBottom,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotivaButton1 extends StatelessWidget {
  const _NotivaButton1({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
          colors: [NotivaColors.buttonTop, NotivaColors.buttonBottom],
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
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpScreen1 extends StatefulWidget {
  const SignUpScreen1({super.key});

  @override
  State<SignUpScreen1> createState() => _SignUpScreen1State();
}

class _SignUpScreen1State extends State<SignUpScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;

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
          Image.asset('assets/images/winter.png', fit: BoxFit.cover),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: NotivaColors.glacial,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Back', style: TextStyle(fontSize: 23)),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.7),
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
                            'Sign Up',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: NotivaColors.glacial,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                  color: NotivaColors.shadow,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          _FancyField1(
                            controller: _user,
                            hint: 'Username',
                            icon: Icons.person_rounded,
                            obscure: false,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter username'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FancyField1(
                            controller: _email,
                            hint: 'Email Address',
                            icon: Icons.email_rounded,
                            obscure: false,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter email address';
                              }
                              final emailRegex = RegExp(
                                r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _FancyField1(
                            controller: _pass,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            obscure: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Enter password'
                                : null,
                          ),
                          const SizedBox(height: 22),
                          _NotivaButton1(
                            label: 'Sign Up',
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final username = _user.text.trim();
                                final email = _email.text.trim();
                                final password = _pass.text;

                                final created = await apiService.signup(
                                  username,
                                  email,
                                  password,
                                );

                                if (created) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Account created successfully!',
                                      ),
                                    ),
                                  );

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HomeScreen1(username: username),
                                    ),
                                  );
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sign up failed'),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(height: 20),
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

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'homescreen_forest.dart';

const String _apiBase = 'http://10.0.2.2:3000';
final ApiService apiService = ApiService(baseUrl: _apiBase);

void main() => runApp(const NotivaApp());

class NotivaApp extends StatelessWidget {
  const NotivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false, fontFamily: 'Roboto'),
      home: const WelcomeScreen(),
    );
  }
}

class NotivaColors {
  static const bgTop = Color(0xFF0F574F);
  static const bgBottom = Color(0xFF2D6B37);
  static const panel = Color(0xFF195F44);
  static const panelBorder = Color(0xFFDB7A1C);
  static const gold = Color(0xFFF5C53A);
  static const buttonTop = Color(0xFFEA8A22);
  static const buttonBottom = Color(0xFFC55C14);
  static const shadow = Colors.black54;
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/forest.jpg'),
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
                  color: NotivaColors.gold,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'NOTIVA',
                style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.w800,
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
                    _NotivaButton(
                      label: 'Login',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _NotivaButton(
                      label: 'Sign Up',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
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
                          const SizedBox(height: 28),
                          _FancyField(
                            controller: _user,
                            hint: 'Username',
                            icon: Icons.person_rounded,
                            obscure: false,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter username'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FancyField(
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
                          _NotivaButton(
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
                                          HomeScreen(username: username),
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
                                  builder: (context) => const SignUpScreen(),
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
                                color: NotivaColors.gold,
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

class _FancyField extends StatelessWidget {
  const _FancyField({
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
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            icon: Icon(icon, color: NotivaColors.gold),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFCBE5D7),
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
                      color: NotivaColors.gold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotivaButton extends StatelessWidget {
  const _NotivaButton({required this.label, required this.onPressed});

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
              color: NotivaColors.gold,
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
                          const SizedBox(height: 28),
                          _FancyField(
                            controller: _user,
                            hint: 'Username',
                            icon: Icons.person_rounded,
                            obscure: false,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter username'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _FancyField(
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
                          _FancyField(
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
                          _NotivaButton(
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
                                          HomeScreen(username: username),
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

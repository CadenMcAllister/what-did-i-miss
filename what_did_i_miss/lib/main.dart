import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'What Did I Miss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter Tight',
        colorScheme: const ColorScheme.light(
          primary: _LightAppColors.primary,
          secondary: _LightAppColors.secondary,
          tertiary: _LightAppColors.tertiary,
          surface: _LightAppColors.secondaryBackground,
          error: _LightAppColors.error,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter Tight',
        colorScheme: const ColorScheme.dark(
          primary: _DarkAppColors.primary,
          secondary: _DarkAppColors.secondary,
          tertiary: _DarkAppColors.tertiary,
          surface: _DarkAppColors.secondaryBackground,
          error: _DarkAppColors.error,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DarkAppColors.primaryBackground,
      appBar: AppBar(
        title: const Text(
          'What Did I Miss?',
          style: TextStyle(
            fontFamily: 'Inter Tight',
          ),
        ),
        backgroundColor: _DarkAppColors.tertiary,
        foregroundColor: _DarkAppColors.primaryText,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // Main Title
                Text(
                  'Get the News You Missed, Instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter Tight',
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: _DarkAppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                // Subtitle
                Text(
                  'We track what matters and summarize it for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter Tight',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: _DarkAppColors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                // Get Started Button
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _DarkAppColors.primary,
                    foregroundColor: _DarkAppColors.primaryText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                // Feature Cards
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeatureCard(
                      icon: Icons.calendar_today,
                      text: 'Pick your offline dates',
                    ),
                    _FeatureCard(
                      icon: Icons.article,
                      text: 'Choose topics you\'re interested in',
                    ),
                    _FeatureCard(
                      icon: Icons.description,
                      text: 'Get a Markdown text summary when you return',
                    ),
                  ],
                ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isSigningUp = false;
  bool _isLoggingIn = false;
  bool _isResettingPassword = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {_SnackBarTone tone = _SnackBarTone.info}) {
    final Color backgroundColor;
    final IconData icon;
    switch (tone) {
      case _SnackBarTone.success:
        backgroundColor = _DarkAppColors.success;
        icon = Icons.check_circle;
        break;
      case _SnackBarTone.warning:
        backgroundColor = _DarkAppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case _SnackBarTone.error:
        backgroundColor = _DarkAppColors.error;
        icon = Icons.error_outline;
        break;
      case _SnackBarTone.info:
        backgroundColor = _DarkAppColors.tertiary;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(icon, color: _DarkAppColors.primaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Inter Tight',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _DarkAppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email and password are required.', tone: _SnackBarTone.warning);
      return;
    }

    setState(() {
      _isSigningUp = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (response.session != null) {
        _showSnackBar('Account created successfully.', tone: _SnackBarTone.success);
        return;
      }
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        _showSnackBar('Account already exists, please log in.', tone: _SnackBarTone.warning);
        return;
      } on AuthException {
        if (!mounted) return;
      }
      _showSnackBar('Check your email to confirm your account.', tone: _SnackBarTone.info);
    } on AuthException catch (error) {
      if (!mounted) return;
      final message = error.message.toLowerCase();
      if (error.statusCode == '409' ||
          message.contains('already registered') ||
          message.contains('already exists') ||
          message.contains('duplicate')) {
        _showSnackBar('That account already exists.', tone: _SnackBarTone.warning);
        return;
      }
      _showSnackBar(error.message, tone: _SnackBarTone.error);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Something went wrong. Please try again.', tone: _SnackBarTone.error);
    } finally {
      if (!mounted) return;
      setState(() {
        _isSigningUp = false;
      });
    }
  }

  Future<void> _signIn() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email and password are required.', tone: _SnackBarTone.warning);
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EmptyPage()),
      );
      _showSnackBar('Logged in successfully.', tone: _SnackBarTone.success);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnackBar(error.message, tone: _SnackBarTone.error);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Something went wrong. Please try again.', tone: _SnackBarTone.error);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _loginEmailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Enter your email to reset your password.', tone: _SnackBarTone.warning);
      return;
    }

    setState(() {
      _isResettingPassword = true;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      _showSnackBar('Password reset email sent.', tone: _SnackBarTone.success);
    } on AuthException catch (error) {
      if (!mounted) return;
      _showSnackBar(error.message, tone: _SnackBarTone.error);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Something went wrong. Please try again.', tone: _SnackBarTone.error);
    } finally {
      if (!mounted) return;
      setState(() {
        _isResettingPassword = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _DarkAppColors.secondaryBackground,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              height: 230,
              margin: const EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _DarkAppColors.primaryBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'What Did I Miss?',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: _DarkAppColors.primaryText,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 600,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: _DarkAppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _DarkAppColors.primaryBackground, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TabBar(
                    dividerColor: _DarkAppColors.tertiary,
                    labelPadding: EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.only(top: 12),
                    tabAlignment: TabAlignment.center,
                    tabs: [
                      Tab(child: Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                      Tab(child: Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 230,
                                height: 40,
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                  color: _DarkAppColors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Text('Create Account', style:
                                TextStyle(
                                  color: _DarkAppColors.primaryText,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600
                                  )
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 24),
                                child: Text('Let\'s get started by filling out the form below.', style: 
                                  TextStyle(
                                    color: _DarkAppColors.secondaryText, 
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w400, 
                                    fontFamily: 'Inter'
                                  )
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: _DarkAppColors.secondaryText),
                                    filled: true,
                                    fillColor: _DarkAppColors.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TextField(
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: _DarkAppColors.secondaryText),
                                    filled: true,
                                    fillColor: _DarkAppColors.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: _DarkAppColors.secondaryText,
                                      ),
                                      tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isSigningUp ? null : _signUp,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _DarkAppColors.primary,
                                    foregroundColor: _DarkAppColors.primaryText,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSigningUp
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontFamily: 'Inter Tight',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),

                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 230,
                                height: 40,
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                  color: _DarkAppColors.secondaryBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Text('Login', style:
                                TextStyle(
                                  color: _DarkAppColors.primaryText,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600
                                  )
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 24),
                                child: Text('Welcome back. Enter your credentials to continue.', style: 
                                  TextStyle(
                                    color: _DarkAppColors.secondaryText, 
                                    fontSize: 14, 
                                    fontWeight: FontWeight.w400, 
                                    fontFamily: 'Inter'
                                  )
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TextField(
                                  controller: _loginEmailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: _DarkAppColors.secondaryText),
                                    filled: true,
                                    fillColor: _DarkAppColors.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TextField(
                                  controller: _loginPasswordController,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    labelStyle: TextStyle(color: _DarkAppColors.secondaryText),
                                    filled: true,
                                    fillColor: _DarkAppColors.primaryBackground,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: _DarkAppColors.secondaryText,
                                      ),
                                      tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                                    ),
                                  ),
                                  obscureText: _obscurePassword,
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isLoggingIn ? null : _signIn,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _DarkAppColors.primary,
                                    foregroundColor: _DarkAppColors.primaryText,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontFamily: 'Inter Tight',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isResettingPassword ? null : _sendPasswordReset,
                                  child: _isResettingPassword
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Text('Forgot password?'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureCard({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _DarkAppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _DarkAppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 48,
              color: _DarkAppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _DarkAppColors.primaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _DarkAppColors.primaryBackground,
      body: SizedBox.shrink(),
    );
  }
}

enum _SnackBarTone { info, success, warning, error }

class _LightAppColors {
  static const primary = Color(0xFF4A90E2);
  static const secondary = Color(0xFF6A7BA2);
  static const tertiary = Color(0xFFA6B8E0);
  static const alternate = Color(0xFFECEFF4);
  static const primaryText = Color(0xFF1F2937);
  static const secondaryText = Color(0xFF6B7280);
  static const primaryBackground = Color(0xFFF8FAFC);
  static const secondaryBackground = Color(0xFFE5EAF0);
  static const accent1 = Color(0xFFFFAD5A);
  static const accent2 = Color(0xFF57D8A4);
  static const accent3 = Color(0xFF7F5AF0);
  static const accent4 = Color(0xFFFFD166);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
}

class _DarkAppColors {
  static const primary = Color(0xFF60A5FA);
  static const secondary = Color(0xFF9CA3AF);
  static const tertiary = Color(0xFF3B3F54);
  static const alternate = Color(0xFF111827);
  static const primaryText = Color(0xFFF9FAFB);
  static const secondaryText = Color(0xFFD1D5DB);
  static const primaryBackground = Color(0xFF111827);
  static const secondaryBackground = Color(0xFF1E2533);
  static const accent1 = Color(0xFFFDBA74);
  static const accent2 = Color(0xFF34D399);
  static const accent3 = Color(0xFFC084FC);
  static const accent4 = Color(0xFFFCD34D);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFF87171);
  static const warning = Color(0xFFFBBF24);
  static const info = Color(0xFF60A5FA);
}

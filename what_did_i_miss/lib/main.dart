import 'package:flutter/material.dart';

void main() {
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
                              Text('Let\'s get started by filling out the form below.', style: 
                                TextStyle(
                                  color: _DarkAppColors.secondaryText, 
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w400, 
                                  fontFamily: 'Inter'
                                )
                              )
                            ],
                          ),
                        ),
                        Center(child: Text('Login Tab', style: TextStyle(color: _DarkAppColors.primaryText))),
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

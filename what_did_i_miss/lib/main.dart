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
        colorScheme: const ColorScheme.light(
          primary: _LightAppColors.primary,
          secondary: _LightAppColors.secondary,
          tertiary: _LightAppColors.tertiary,
          background: _LightAppColors.primaryBackground,
          surface: _LightAppColors.secondaryBackground,
          error: _LightAppColors.error,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: _DarkAppColors.primary,
          secondary: _DarkAppColors.secondary,
          tertiary: _DarkAppColors.tertiary,
          background: _DarkAppColors.primaryBackground,
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('What Did I Miss?'),
        backgroundColor: theme.colorScheme.tertiary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This is your starting point. Add sections here for recent updates, notes, or anything else your app needs.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        // TODO: Navigate to your first feature.
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Get started'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: Add a secondary action.
                      },
                      child: const Text('Learn more'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                const Divider(),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    _HomeInfoCard(
                      icon: Icons.update,
                      title: 'Recent activity',
                      description:
                          'Show a summary of what changed since you last visited.',
                    ),
                    _HomeInfoCard(
                      icon: Icons.list_alt,
                      title: 'Tasks',
                      description:
                          'List the things you still need to catch up on.',
                    ),
                    _HomeInfoCard(
                      icon: Icons.timeline,
                      title: 'Timeline',
                      description:
                          'Visualize events or changes over time.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HomeInfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 240,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
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

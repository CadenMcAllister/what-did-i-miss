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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
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

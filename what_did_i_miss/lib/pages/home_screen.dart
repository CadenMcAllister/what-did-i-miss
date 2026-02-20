import 'package:flutter/material.dart';

import '../app/theme_mode_scope.dart';
import '../pages/login_page.dart';
import '../theme/app_colors.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).primaryBackground,
      appBar: AppBar(
        title: const Text(
          'What Did I Miss?',
          style: TextStyle(
            fontFamily: 'Inter Tight',
          ),
        ),
        backgroundColor: AppColors.of(context).tertiary,
        foregroundColor: AppColors.of(context).primaryText,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ThemeModeScope.of(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final scope = ThemeModeScope.of(context);
              scope.setThemeMode(
                scope.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
            tooltip: ThemeModeScope.of(context).themeMode == ThemeMode.dark
                ? 'Switch to light mode'
                : 'Switch to dark mode',
          ),
        ],
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
                        color: AppColors.of(context).primaryText,
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
                        color: AppColors.of(context).secondaryText,
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
                        backgroundColor: AppColors.of(context).primary,
                        foregroundColor: AppColors.of(context).primaryText,
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
                        FeatureCard(
                          icon: Icons.calendar_today,
                          text: 'Pick your offline dates',
                        ),
                        FeatureCard(
                          icon: Icons.article,
                          text: 'Choose topics you\'re interested in',
                        ),
                        FeatureCard(
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

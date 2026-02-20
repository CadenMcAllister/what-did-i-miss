import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: DarkAppColors.primaryBackground,
      body: SizedBox.shrink(),
    );
  }
}

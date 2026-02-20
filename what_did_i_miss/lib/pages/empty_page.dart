import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).primaryBackground,
      body: const SizedBox.shrink(),
    );
  }
}

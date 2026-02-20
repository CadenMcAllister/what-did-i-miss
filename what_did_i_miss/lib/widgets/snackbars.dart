import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SnackBarTone { info, success, warning, error }

void showAppSnackBar(BuildContext context, String message,
    {SnackBarTone tone = SnackBarTone.info}) {
  final Color backgroundColor;
  final IconData icon;
  switch (tone) {
    case SnackBarTone.success:
      backgroundColor = DarkAppColors.success;
      icon = Icons.check_circle;
      break;
    case SnackBarTone.warning:
      backgroundColor = DarkAppColors.warning;
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarTone.error:
      backgroundColor = DarkAppColors.error;
      icon = Icons.error_outline;
      break;
    case SnackBarTone.info:
      backgroundColor = DarkAppColors.tertiary;
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
          Icon(icon, color: DarkAppColors.primaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter Tight',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DarkAppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

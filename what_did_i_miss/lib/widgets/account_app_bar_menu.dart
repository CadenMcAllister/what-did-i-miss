import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app/routes.dart';
import '../theme/app_colors.dart';

/// Prefer Supabase `user_metadata.display_name`, else email local part (matches login flow).
String accountDisplayLabel(User? user) {
  if (user == null) return '';
  final meta = user.userMetadata?['display_name'] as String?;
  if (meta != null && meta.trim().isNotEmpty) return meta.trim();
  final email = user.email;
  if (email == null || email.isEmpty) return '';
  final at = email.indexOf('@');
  if (at <= 0) return email;
  return email.substring(0, at);
}

void openDashboardIfNeeded(BuildContext context) {
  final current = ModalRoute.of(context)?.settings.name;
  if (current == AppRoutes.dashboard) return;
  Navigator.pushNamed(context, AppRoutes.dashboard);
}

Future<void> signOutAndNavigateToLogin(BuildContext context) async {
  await Supabase.instance.client.auth.signOut();
  if (context.mounted) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}

/// Avatar + name chip: Dashboard and Sign out when signed in.
class AccountAppBarMenu extends StatelessWidget {
  const AccountAppBarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();

    final colors = AppColors.of(context);
    final raw = accountDisplayLabel(user);
    final label = raw.isEmpty ? 'Account' : raw;
    final initial = _initialForLabel(label);

    final baseTheme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 6, left: 2),
      child: Theme(
        data: baseTheme.copyWith(
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          popupMenuTheme: baseTheme.popupMenuTheme.copyWith(
            enableFeedback: false,
          ),
        ),
        child: PopupMenuButton<String>(
          tooltip: 'Account',
          padding: EdgeInsets.zero,
          splashRadius: 0,
          enableFeedback: false,
          offset: const Offset(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          color: colors.secondaryBackground,
          elevation: 8,
          shadowColor: colors.primaryText.withValues(alpha: 0.12),
          onSelected: (value) {
            if (value == 'dashboard') {
              openDashboardIfNeeded(context);
            } else if (value == 'signOut') {
              signOutAndNavigateToLogin(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'dashboard',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.space_dashboard_outlined,
                    size: 22,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'signOut',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    size: 22,
                    color: colors.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sign out',
                    style: TextStyle(
                      fontFamily: 'Inter Tight',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: colors.primaryText.withValues(alpha: 0.12),
              ),
              color: colors.primaryBackground.withValues(alpha: 0.55),
              boxShadow: [
                BoxShadow(
                  color: colors.primaryText.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 5, 8, 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colors.primary.withValues(alpha: 0.22),
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryText,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 118),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: colors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 22,
                    color: colors.secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _initialForLabel(String label) {
  if (label.isEmpty) return '?';
  final runes = label.runes;
  if (runes.isEmpty) return '?';
  return String.fromCharCode(runes.first).toUpperCase();
}

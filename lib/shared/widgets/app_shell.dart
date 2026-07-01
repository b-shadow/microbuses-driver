import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/router/app_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.showBack = true,
    this.showAuthButton = true,
    this.onToggleTheme,
  });

  final String title;
  final Widget body;
  final bool showBack;
  final bool showAuthButton;
  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgTop = isDark ? const Color(0xFF020617) : const Color(0xFFEFF6FF);
    final bgMid = isDark ? const Color(0xFF031525) : const Color(0xFFDBEAFE);
    final bgBottom = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgTop, bgMid, bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 390;
              final actionSize = compact ? 42.0 : 46.0;
              final titleSize = compact ? 18.0 : 24.0;
              final authPadding = compact
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

              BoxDecoration topbarDecoration() => BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFBFDBFE),
                    ),
                  );

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(compact ? 10 : 12, 10, compact ? 10 : 12, 8),
                    child: Row(
                      children: [
                        if (showBack) ...[
                          Container(
                            width: actionSize,
                            height: actionSize,
                            decoration: topbarDecoration(),
                            child: IconButton(
                              onPressed: () {
                                final navigator = Navigator.of(context);
                                if (navigator.canPop()) {
                                  navigator.pop();
                                } else {
                                  navigator.pushNamedAndRemoveUntil(AppRouter.home, (_) => false);
                                }
                              },
                              icon: Icon(Icons.arrow_back, color: textColor, size: compact ? 20 : 24),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (onToggleTheme != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: actionSize,
                            height: actionSize,
                            decoration: topbarDecoration(),
                            child: IconButton(
                              onPressed: onToggleTheme,
                              icon: Icon(
                                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                color: textColor,
                                size: compact ? 20 : 24,
                              ),
                            ),
                          ),
                        ],
                        if (showAuthButton) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: FutureBuilder<bool>(
                              future: _hasSession(),
                              builder: (_, snapshot) {
                                final hasSession = snapshot.data ?? false;
                                return FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark
                                          ? const Color(0xFFBAE6FD)
                                          : const Color(0xFF0F4C81),
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.24)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      padding: authPadding,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      backgroundColor: isDark
                                          ? Colors.transparent
                                          : Colors.white.withValues(alpha: 0.45),
                                    ),
                                    onPressed: () async {
                                      if (hasSession) {
                                        await _logout();
                                        if (context.mounted) {
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            AppRouter.login,
                                            (_) => false,
                                          );
                                        }
                                      } else {
                                        Navigator.pushNamed(context, AppRouter.login);
                                      }
                                    },
                                    icon: FaIcon(
                                      hasSession
                                          ? FontAwesomeIcons.rightFromBracket
                                          : FontAwesomeIcons.rightToBracket,
                                      size: compact ? 12 : 14,
                                    ),
                                    label: Text(hasSession ? 'Cerrar sesion' : 'Iniciar sesion'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(child: body),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('driver_access_token') ?? '').isNotEmpty;
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('driver_access_token');
    await prefs.remove('driver_active_trip_id');
    await prefs.remove('driver_active_trip_started_at');
  }
}

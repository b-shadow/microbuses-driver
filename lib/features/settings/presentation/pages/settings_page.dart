import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/settings_controller.dart';

class DriverSettingsPage extends StatefulWidget {
  const DriverSettingsPage({super.key, this.onToggleTheme});

  final VoidCallback? onToggleTheme;

  @override
  State<DriverSettingsPage> createState() => _DriverSettingsPageState();
}

class _DriverSettingsPageState extends State<DriverSettingsPage> {
  final _controller = SettingsController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Settings',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                const DriverHeroCard(
                  title: 'Sesion y seguridad',
                  subtitle: 'Administra el cierre de sesion del conductor y mantiene limpio el contexto operativo del dispositivo.',
                  trailing: FaIcon(FontAwesomeIcons.shieldHalved, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 18),
                DriverListCard(
                  title: 'Salida de cuenta',
                  subtitle: 'Elimina el token local y vuelve a la pantalla de autenticacion.',
                  icon: FontAwesomeIcons.rightFromBracket,
                  footer: ElevatedButton(
                    onPressed: () async {
                      await _controller.logout();
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (_) => false);
                    },
                    child: const Text('Cerrar sesion'),
                  ),
                ),
                StatusBanner(text: _controller.status),
              ],
            ),
          ),
        ),
      );
}

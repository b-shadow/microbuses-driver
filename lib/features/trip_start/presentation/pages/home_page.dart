import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_ui.dart';

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final items = <({String title, String subtitle, String route, IconData icon, Color color})>[
      (
        title: 'Buses',
        subtitle: 'Consulta tu flota y agrega nuevas unidades.',
        route: AppRouter.myBuses,
        icon: FontAwesomeIcons.busSimple,
        color: const Color(0xFF2563EB),
      ),
      (
        title: 'Gestionar recorrido',
        subtitle: 'Selecciona unidad, define linea e inicia o controla la jornada.',
        route: AppRouter.startTrip,
        icon: FontAwesomeIcons.play,
        color: const Color(0xFF22C55E),
      ),
      (
        title: 'Perfil',
        subtitle: 'Revisa tu cuenta y estado operativo.',
        route: AppRouter.profile,
        icon: FontAwesomeIcons.idBadge,
        color: const Color(0xFF8B5CF6),
      ),
      (
        title: 'Auditoria',
        subtitle: 'Revisa acciones y eventos recientes.',
        route: AppRouter.audit,
        icon: FontAwesomeIcons.clockRotateLeft,
        color: const Color(0xFFEAB308),
      ),
    ];

    return AppShell(
      title: 'Panel conductor',
      showBack: false,
      onToggleTheme: onToggleTheme,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 380;
          final crossAxisCount = width >= 760 ? 3 : 2;
          final childAspectRatio = width < 360 ? 0.84 : width < 430 ? 0.92 : 1.02;

          return ListView(
            padding: EdgeInsets.fromLTRB(isCompact ? 12 : 16, 10, isCompact ? 12 : 16, 24),
            children: [
              const DriverHeroCard(
                title: 'Operacion de conductor',
                subtitle: 'Selecciona microbus, activa recorrido y manten el tracking estable durante toda la jornada.',
                trailing: FaIcon(FontAwesomeIcons.bus, size: 42, color: Colors.white),
              ),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(
                    child: DriverMetricCard(
                      title: 'Estado',
                      value: 'Listo para salir',
                      icon: FontAwesomeIcons.circleCheck,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DriverMetricCard(
                      title: 'GPS',
                      value: 'Cada 10 s',
                      icon: FontAwesomeIcons.locationArrow,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const DriverSectionLabel('Accesos rapidos'),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return DriverActionCard(
                    title: item.title,
                    subtitle: item.subtitle,
                    icon: item.icon,
                    color: item.color,
                    onTap: () => Navigator.pushNamed(context, item.route),
                  );
                },
              ),
              const SizedBox(height: 12),
              const DriverSectionLabel('Checklist antes de salir'),
              const DriverListCard(
                title: 'Verificacion operativa',
                subtitle: 'Confirma seleccion de microbus, linea operativa, conexion a internet y permisos de ubicacion en segundo plano.',
                icon: FontAwesomeIcons.listCheck,
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/bus_assignment_controller.dart';

class MyBusesPage extends StatefulWidget {
  const MyBusesPage({super.key, this.autoLoad = true, this.onToggleTheme});

  final bool autoLoad;
  final VoidCallback? onToggleTheme;

  @override
  State<MyBusesPage> createState() => _MyBusesPageState();
}

class _MyBusesPageState extends State<MyBusesPage> {
  final _controller = BusAssignmentController();

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) _controller.loadBuses();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Buses',
        onToggleTheme: widget.onToggleTheme,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: ListView(
              children: [
                const DriverHeroCard(
                  title: 'Gestion de buses',
                  subtitle: 'Consulta tus unidades disponibles, revisa la linea asignada y agrega nuevos microbuses a tu cuenta operativa.',
                  trailing: FaIcon(FontAwesomeIcons.bus, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Unidades',
                        value: '${_controller.buses.length}',
                        icon: FontAwesomeIcons.busSimple,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Estado',
                        value: _controller.buses.isEmpty ? 'Sin flota' : 'Disponible',
                        icon: FontAwesomeIcons.circleCheck,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final created = await Navigator.pushNamed(context, AppRouter.registerBus);
                      if (created == true && mounted) {
                        await _controller.loadBuses();
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agregar bus'),
                  ),
                ),
                const SizedBox(height: 12),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudieron')),
                const SizedBox(height: 12),
                if (_controller.buses.isEmpty)
                  const EmptyStateCard(title: 'Sin buses', subtitle: 'Registra una unidad para empezar a operar.')
                else
                  ..._controller.buses.map(
                    (bus) => DriverListCard(
                      title: '${bus['plate'] ?? ''} - ${bus['model'] ?? ''}',
                      subtitle: 'Linea: ${bus['line_id'] ?? bus['current_line_id'] ?? '-'}',
                      icon: FontAwesomeIcons.busSimple,
                      footer: Row(
                        children: [
                          Expanded(
                            child: DriverMetricCard(
                              title: 'Asientos',
                              value: '${bus['seat_count'] ?? bus['seats'] ?? '-'}',
                              icon: FontAwesomeIcons.chair,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DriverMetricCard(
                              title: 'Interno',
                              value: '${bus['internal_number'] ?? bus['unit_number'] ?? '-'}',
                              icon: FontAwesomeIcons.hashtag,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

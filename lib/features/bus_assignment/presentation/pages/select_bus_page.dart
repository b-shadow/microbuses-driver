import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/bus_assignment_controller.dart';

class SelectBusPage extends StatefulWidget {
  const SelectBusPage({super.key, this.autoLoad = true, this.onToggleTheme});

  final bool autoLoad;
  final VoidCallback? onToggleTheme;

  @override
  State<SelectBusPage> createState() => _SelectBusPageState();
}

class _SelectBusPageState extends State<SelectBusPage> {
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
        title: 'Seleccionar microbus',
        onToggleTheme: widget.onToggleTheme,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              children: [
                const DriverHeroCard(
                  title: 'Selecciona tu microbus',
                  subtitle: 'El vehiculo elegido quedara listo para iniciar recorrido y asociar la linea operativa actual.',
                  trailing: FaIcon(FontAwesomeIcons.checkToSlot, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 16),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudieron')),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _controller.buses.length,
                    itemBuilder: (_, i) {
                      final bus = _controller.buses[i] as Map<String, dynamic>;
                      final lineId = (bus['line_id'] ?? bus['current_line_id'] ?? '').toString();
                      return DriverListCard(
                        title: '${bus['plate'] ?? ''} - ${bus['model'] ?? ''}',
                        subtitle: 'Linea actual: ${lineId.isEmpty ? '-' : lineId}',
                        icon: FontAwesomeIcons.busSimple,
                        trailing: SizedBox(
                          width: 110,
                          child: ElevatedButton(
                            onPressed: () => _controller.selectBus(
                              busId: (bus['id'] ?? '').toString(),
                              lineId: lineId,
                            ),
                            child: const Text('Usar'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

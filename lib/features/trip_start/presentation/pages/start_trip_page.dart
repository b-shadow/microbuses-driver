import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../../../shared/widgets/driver_operation_map.dart';
import '../../application/controllers/trip_start_controller.dart';

class StartTripPage extends StatefulWidget {
  const StartTripPage({
    super.key,
    this.onToggleTheme,
    this.autoLoad = true,
    this.showMap = true,
  });

  final VoidCallback? onToggleTheme;
  final bool autoLoad;
  final bool showMap;

  @override
  State<StartTripPage> createState() => _StartTripPageState();
}

class _StartTripPageState extends State<StartTripPage> {
  final _controller = TripStartController();
  String? _selectedLineId;

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      _loadContext();
    }
  }

  Future<void> _loadContext() async {
    await _controller.loadContext();
    _selectedLineId = _controller.selectedLineId.isEmpty ? null : _controller.selectedLineId;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatHour(DateTime? value) {
    if (value == null) return '-';
    final local = value.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Gestionar recorrido',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                DriverHeroCard(
                  title: _controller.activeTripId.isNotEmpty ? 'Recorrido en curso' : 'Preparacion de jornada',
                  subtitle: _controller.activeTripId.isNotEmpty
                      ? 'Ya existe un viaje activo. Desde aqui puedes ver el mapa operativo, revisar el inicio y cerrar la jornada cuando termine.'
                      : 'Selecciona el microbus operativo y define la linea antes de activar el recorrido.',
                  trailing: FaIcon(
                    _controller.activeTripId.isNotEmpty ? FontAwesomeIcons.satelliteDish : FontAwesomeIcons.play,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Conexion',
                        value: 'Requerida',
                        icon: FontAwesomeIcons.wifi,
                        color: Color(0xFF0EA5E9),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DriverMetricCard(
                        title: 'GPS',
                        value: 'Segundo plano',
                        icon: FontAwesomeIcons.locationDot,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (widget.showMap) ...[
                  DriverOperationMap(
                    center: LatLng(_controller.currentLat, _controller.currentLng),
                    height: 250,
                  ),
                  const SizedBox(height: 18),
                ],
                if (_controller.activeTripId.isNotEmpty) ...[
                  DriverListCard(
                    title: 'Operacion bloqueada por viaje activo',
                    subtitle: 'Trip ID: ${_controller.activeTripId}',
                    icon: FontAwesomeIcons.lock,
                    footer: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DriverMetricCard(
                                title: 'Microbus',
                                value: _controller.selectedBus?['plate']?.toString() ?? _controller.selectedBusId,
                                icon: FontAwesomeIcons.busSimple,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DriverMetricCard(
                                title: 'Linea',
                                value: _controller.selectedLineId.isEmpty ? '-' : _controller.selectedLineName,
                                icon: FontAwesomeIcons.route,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DriverMetricCard(
                          title: 'Inicio',
                          value: _formatHour(_controller.activeTripStartedAt),
                          icon: FontAwesomeIcons.clock,
                          color: const Color(0xFF22C55E),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pushNamed(context, AppRouter.activeTrip),
                                child: const Text('Ver viaje activo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, AppRouter.finishTrip),
                                child: const Text('Finalizar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  DriverListCard(
                    title: 'Microbus seleccionado',
                    subtitle: _controller.selectedBus == null
                        ? 'Aun no elegiste con que unidad saldras hoy.'
                        : '${_controller.selectedBus?['plate'] ?? ''} - ${_controller.selectedBus?['model'] ?? ''}',
                    icon: FontAwesomeIcons.busSimple,
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_controller.selectedBus != null) ...[
                          DriverMetricCard(
                            title: 'Linea actual',
                            value: _selectedLineId == null || _selectedLineId!.isEmpty ? '-' : _controller.selectedLineName,
                            icon: FontAwesomeIcons.route,
                            color: const Color(0xFFF59E0B),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedLineId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Linea operativa',
                              prefixIcon: Icon(Icons.alt_route_rounded),
                            ),
                            items: _controller.lines
                                .map(
                                  (line) => DropdownMenuItem<String>(
                                    value: line.id,
                                    child: Text(line.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _controller.isLoading
                                ? null
                                : (value) async {
                                    if (value == null) return;
                                    setState(() => _selectedLineId = value);
                                    await _controller.changeLine(value);
                                  },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const DriverSectionLabel('Selecciona con que microbus saldras'),
                  if (_controller.buses.isEmpty)
                    const DriverListCard(
                      title: 'Sin microbuses disponibles',
                      subtitle: 'Primero registra una unidad en el modulo Buses para poder iniciar recorridos.',
                      icon: FontAwesomeIcons.busSimple,
                    )
                  else
                    ..._controller.buses.map(
                      (bus) {
                        final busId = (bus['id'] ?? '').toString();
                        final isSelected = busId == _controller.selectedBusId;
                        return DriverListCard(
                          title: '${bus['plate'] ?? ''} - ${bus['model'] ?? ''}',
                          subtitle: 'Linea actual: ${bus['line_id'] ?? '-'}',
                          icon: isSelected ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.busSimple,
                          trailing: SizedBox(
                            width: 110,
                            child: ElevatedButton(
                              onPressed: _controller.isLoading ? null : () => _controller.selectBus(busId),
                              child: Text(isSelected ? 'Activo' : 'Elegir'),
                            ),
                          ),
                        );
                      },
                    ),
                ],
                const DriverSectionLabel('Checklist'),
                const DriverListCard(
                  title: 'Antes de iniciar',
                  subtitle: 'Verifica internet, permisos de ubicacion y que el microbus seleccionado corresponda a tu operacion actual.',
                  icon: FontAwesomeIcons.listCheck,
                ),
                if (_controller.activeTripId.isEmpty)
                  ElevatedButton(
                    onPressed: _controller.isLoading || _controller.selectedBusId.isEmpty || _selectedLineId == null || _selectedLineId!.isEmpty
                        ? null
                        : () async {
                            final tripId = await _controller.startTrip(
                              busId: _controller.selectedBusId,
                              lineId: _selectedLineId!,
                            );
                            if (tripId != null && mounted) {
                              Navigator.pushReplacementNamed(context, AppRouter.activeTrip);
                            }
                          },
                    child: Text(_controller.isLoading ? 'Iniciando...' : 'Iniciar recorrido'),
                  ),
                const SizedBox(height: 12),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo')),
              ],
            ),
          ),
        ),
      );
}

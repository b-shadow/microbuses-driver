import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../../../shared/widgets/driver_operation_map.dart';
import '../../application/controllers/active_trip_controller.dart';

class ActiveTripPage extends StatefulWidget {
  const ActiveTripPage({
    super.key,
    this.onToggleTheme,
    this.autoLoad = true,
    this.showMap = true,
  });

  final VoidCallback? onToggleTheme;
  final bool autoLoad;
  final bool showMap;

  @override
  State<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends State<ActiveTripPage> {
  final _controller = ActiveTripController();

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      _init();
    }
  }

  Future<void> _init() async {
    await _controller.loadActiveTrip();
    await _controller.startTracking();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Viaje activo',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                DriverHeroCard(
                  title: 'Seguimiento en curso',
                  subtitle: _controller.isRunning
                      ? 'El tracking esta activo y seguira enviando ubicacion cada 10 segundos.'
                      : 'Carga el viaje activo para reanudar el seguimiento.',
                  trailing: FaIcon(
                    _controller.isRunning ? FontAwesomeIcons.satellite : FontAwesomeIcons.pause,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                if (widget.showMap) ...[
                  DriverOperationMap(
                    center: LatLng(_controller.currentLat, _controller.currentLng),
                    height: 280,
                  ),
                  const SizedBox(height: 18),
                ],
                Row(
                  children: [
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Inicio',
                        value: _controller.startedAt == null ? 'Pendiente' : _controller.startedAt!.toLocal().toString().substring(11, 16),
                        icon: FontAwesomeIcons.clock,
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Ultimo envio',
                        value: _controller.lastSentAt == null ? 'Pendiente' : 'Sincronizado',
                        icon: FontAwesomeIcons.clock,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                DriverListCard(
                  title: 'Estado de seguimiento',
                  subtitle: _controller.lastSentAt == null
                      ? 'Trip ID: ${_controller.activeTripId.isEmpty ? '-' : _controller.activeTripId}'
                      : 'Trip ID: ${_controller.activeTripId}\nUltima ubicacion enviada: ${_controller.lastSentAt}',
                  icon: FontAwesomeIcons.locationArrow,
                  footer: StatusBanner(
                    text: _controller.status,
                    isError: _controller.status.contains('Sin conexion') || _controller.status.contains('pendiente'),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _controller.sendNow, child: const Text('Enviar ahora')),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await _controller.stopTracking();
                    if (context.mounted) {
                      Navigator.pushNamed(context, AppRouter.finishTrip);
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.flagCheckered, size: 14),
                  label: const Text('Finalizar recorrido'),
                ),
              ],
            ),
          ),
        ),
      );
}

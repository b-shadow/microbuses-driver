import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../../../shared/widgets/driver_operation_map.dart';
import '../../application/controllers/trip_finish_controller.dart';

class FinishTripPage extends StatefulWidget {
  const FinishTripPage({
    super.key,
    this.onToggleTheme,
    this.showMap = true,
  });

  final VoidCallback? onToggleTheme;
  final bool showMap;

  @override
  State<FinishTripPage> createState() => _FinishTripPageState();
}

class _FinishTripPageState extends State<FinishTripPage> {
  final _controller = TripFinishController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Finalizar recorrido',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                const DriverHeroCard(
                  title: 'Cierre de recorrido',
                  subtitle: 'Confirma el cierre unicamente cuando el viaje haya terminado. Esto detendra el tracking y liberara tu operacion.',
                  trailing: FaIcon(FontAwesomeIcons.flagCheckered, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 18),
                if (widget.showMap) ...[
                  const DriverOperationMap(
                    center: LatLng(-17.7833, -63.1821),
                    height: 240,
                  ),
                  const SizedBox(height: 18),
                ],
                const DriverListCard(
                  title: 'Accion irreversible',
                  subtitle: 'Una vez finalizado, el servicio GPS se detendra y deberas iniciar un nuevo recorrido para volver a operar.',
                  icon: FontAwesomeIcons.triangleExclamation,
                ),
                if (_controller.startedAt != null || _controller.finishedAt != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DriverMetricCard(
                          title: 'Inicio',
                          value: _controller.startedAt == null ? '-' : _controller.startedAt!.toLocal().toString().substring(11, 16),
                          icon: FontAwesomeIcons.clock,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DriverMetricCard(
                          title: 'Finalizacion',
                          value: _controller.finishedAt == null ? '-' : _controller.finishedAt!.toLocal().toString().substring(11, 16),
                          icon: FontAwesomeIcons.flagCheckered,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _controller.isLoading
                      ? null
                      : () async {
                          final ok = await _controller.finishCurrentTrip();
                          if (ok && mounted) {
                            setState(() {});
                          }
                        },
                  child: Text(_controller.isLoading ? 'Finalizando...' : 'Confirmar finalizacion'),
                ),
                if (_controller.finishedAt != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (_) => false),
                    child: const Text('Volver al panel'),
                  ),
                ],
                const SizedBox(height: 12),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo')),
              ],
            ),
          ),
        ),
      );
}

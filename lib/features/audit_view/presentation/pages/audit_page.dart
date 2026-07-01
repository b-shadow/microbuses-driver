import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/audit_view_controller.dart';

class AuditPage extends StatefulWidget {
  const AuditPage({super.key, this.autoLoad = true, this.onToggleTheme});

  final bool autoLoad;
  final VoidCallback? onToggleTheme;

  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  final _controller = AuditViewController();

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) _controller.loadAudit();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Auditoria',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                const DriverHeroCard(
                  title: 'Bitacora operativa',
                  subtitle: 'Consulta eventos registrados por el backend sobre cambios y acciones relevantes del conductor.',
                  trailing: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 38, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Eventos',
                        value: '${_controller.rows.length}',
                        icon: FontAwesomeIcons.fileWaveform,
                        color: const Color(0xFFEAB308),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Estado',
                        value: _controller.rows.isEmpty ? 'Sin actividad' : 'Con registros',
                        icon: FontAwesomeIcons.shield,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo')),
                const SizedBox(height: 12),
                if (_controller.rows.isEmpty)
                  const EmptyStateCard(title: 'Sin eventos', subtitle: 'No se encontraron registros de auditoria para mostrar.')
                else
                  ..._controller.rows.map(
                    (row) => DriverListCard(
                      title: '${row['action'] ?? 'Evento'} - ${row['entity'] ?? 'Entidad'}',
                      subtitle: '${row['created_at'] ?? ''}',
                      icon: FontAwesomeIcons.fileWaveform,
                      footer: Row(
                        children: [
                          Expanded(
                            child: DriverMetricCard(
                              title: 'Usuario',
                              value: '${row['user_id'] ?? row['actor_id'] ?? '-'}',
                              icon: FontAwesomeIcons.user,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DriverMetricCard(
                              title: 'Entidad',
                              value: '${row['entity'] ?? '-'}',
                              icon: FontAwesomeIcons.database,
                              color: const Color(0xFF0EA5E9),
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

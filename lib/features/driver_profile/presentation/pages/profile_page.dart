import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/driver_profile_controller.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key, this.autoLoad = true, this.onToggleTheme});

  final bool autoLoad;
  final VoidCallback? onToggleTheme;

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final _controller = DriverProfileController();

  String _pickValue(List<String> keys) {
    for (final key in keys) {
      final value = _controller.profile[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '-';
  }

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) _controller.loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Perfil conductor',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                const DriverHeroCard(
                  title: 'Perfil del conductor',
                  subtitle: 'Consulta tu cuenta operativa, el estado reconocido por plataforma y la informacion sincronizada del backend.',
                  trailing: FaIcon(FontAwesomeIcons.idBadge, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 18),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Estado',
                        value: _pickValue(['status', 'approval_status', 'driver_status']),
                        icon: FontAwesomeIcons.circleCheck,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DriverMetricCard(
                        title: 'Cuenta',
                        value: _pickValue(['email']),
                        icon: FontAwesomeIcons.at,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DriverListCard(
                  title: 'Informacion personal',
                  subtitle: 'Datos principales asociados a la cuenta del conductor.',
                  icon: FontAwesomeIcons.userCheck,
                  footer: Column(
                    children: [
                      DriverMetricCard(
                        title: 'Nombre',
                        value: _pickValue(['full_name', 'names', 'name']),
                        icon: FontAwesomeIcons.user,
                        color: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 12),
                      DriverMetricCard(
                        title: 'Telefono',
                        value: _pickValue(['phone', 'phone_number']),
                        icon: FontAwesomeIcons.phone,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(height: 12),
                      DriverMetricCard(
                        title: 'Documento',
                        value: _pickValue(['document_number', 'document', 'license_number']),
                        icon: FontAwesomeIcons.idCard,
                        color: const Color(0xFF0EA5E9),
                      ),
                    ],
                  ),
                ),
                DriverListCard(
                  title: 'Respuesta tecnica del backend',
                  subtitle: 'Vista util para soporte y validacion de permisos de sesion.',
                  icon: FontAwesomeIcons.userCheck,
                  footer: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF0B1220)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E3A5F)
                            : const Color(0xFFDBEAFE),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        _controller.profileJson,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.55,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

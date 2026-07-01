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

  String? _pickOptionalValue(List<String> keys) {
    final value = _pickValue(keys);
    return value == '-' ? null : value;
  }

  String? _fullName() {
    final direct = _pickOptionalValue(['full_name', 'name']);
    if (direct != null) return direct;

    final names = _pickOptionalValue(['names']);
    final lastNames = _pickOptionalValue(['last_names']);
    final combined = [names, lastNames].whereType<String>().where((item) => item.trim().isNotEmpty).join(' ');
    if (combined.trim().isEmpty) return null;
    return combined.trim();
  }

  List<_ProfileField> _accountFields() {
    final fields = <_ProfileField>[
      _ProfileField(
        label: 'Correo',
        value: _pickOptionalValue(['email']),
        icon: FontAwesomeIcons.at,
        color: const Color(0xFF2563EB),
      ),
      _ProfileField(
        label: 'Estado',
        value: _pickOptionalValue(['status', 'approval_status', 'driver_status']),
        icon: FontAwesomeIcons.circleCheck,
        color: const Color(0xFF22C55E),
      ),
      _ProfileField(
        label: 'Rol',
        value: _pickOptionalValue(['role']),
        icon: FontAwesomeIcons.userShield,
        color: const Color(0xFF8B5CF6),
      ),
      _ProfileField(
        label: 'ID',
        value: _pickOptionalValue(['id']),
        icon: FontAwesomeIcons.fingerprint,
        color: const Color(0xFFF59E0B),
      ),
    ];
    return fields.where((field) => field.value != null && field.value!.trim().isNotEmpty).toList();
  }

  List<_ProfileField> _personalFields() {
    final fields = <_ProfileField>[
      _ProfileField(
        label: 'Nombre',
        value: _fullName(),
        icon: FontAwesomeIcons.user,
        color: const Color(0xFF8B5CF6),
      ),
      _ProfileField(
        label: 'Telefono',
        value: _pickOptionalValue(['phone', 'phone_number']),
        icon: FontAwesomeIcons.phone,
        color: const Color(0xFFF59E0B),
      ),
      _ProfileField(
        label: 'Documento',
        value: _pickOptionalValue(['ci', 'document_number', 'document', 'license_number']),
        icon: FontAwesomeIcons.idCard,
        color: const Color(0xFF0EA5E9),
      ),
      _ProfileField(
        label: 'Categoria licencia',
        value: _pickOptionalValue(['license_category']),
        icon: FontAwesomeIcons.idBadge,
        color: const Color(0xFFEC4899),
      ),
    ];
    return fields.where((field) => field.value != null && field.value!.trim().isNotEmpty).toList();
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
            builder: (_, __) {
              final accountFields = _accountFields();
              final personalFields = _personalFields();

              return ListView(
                children: [
                  const DriverHeroCard(
                    title: 'Perfil del conductor',
                    subtitle: 'Consulta tu cuenta operativa, el estado reconocido por plataforma y la informacion sincronizada del backend.',
                    trailing: FaIcon(FontAwesomeIcons.idBadge, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo')),
                  const SizedBox(height: 12),
                  if (accountFields.isNotEmpty)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: accountFields
                          .map(
                            (field) => SizedBox(
                              width: MediaQuery.of(context).size.width > 520
                                  ? (MediaQuery.of(context).size.width - 56) / 2
                                  : double.infinity,
                              child: DriverMetricCard(
                                title: field.label,
                                value: field.value!,
                                icon: field.icon,
                                color: field.color,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (accountFields.isNotEmpty) const SizedBox(height: 12),
                  if (personalFields.isNotEmpty)
                    DriverListCard(
                      title: 'Informacion personal',
                      subtitle: 'Datos principales asociados a la cuenta del conductor.',
                      icon: FontAwesomeIcons.userCheck,
                      footer: Column(
                        children: [
                          for (var i = 0; i < personalFields.length; i++) ...[
                            DriverMetricCard(
                              title: personalFields[i].label,
                              value: personalFields[i].value!,
                              icon: personalFields[i].icon,
                              color: personalFields[i].color,
                            ),
                            if (i < personalFields.length - 1) const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
}

class _ProfileField {
  const _ProfileField({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String? value;
  final IconData icon;
  final Color color;
}

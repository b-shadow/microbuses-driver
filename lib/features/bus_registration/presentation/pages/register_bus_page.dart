import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/bus_registration_controller.dart';

class RegisterBusPage extends StatefulWidget {
  const RegisterBusPage({super.key, this.onToggleTheme, this.autoLoad = true});

  final VoidCallback? onToggleTheme;
  final bool autoLoad;

  @override
  State<RegisterBusPage> createState() => _RegisterBusPageState();
}

class _RegisterBusPageState extends State<RegisterBusPage> {
  final _controller = BusRegistrationController();
  final _plate = TextEditingController();
  final _model = TextEditingController();
  final _seats = TextEditingController(text: '20');
  final _internal = TextEditingController();
  int? _selectedLineId;

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      _controller.loadLines();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _plate.dispose();
    _model.dispose();
    _seats.dispose();
    _internal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Registrar microbus',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const DriverHeroCard(
                  title: 'Nuevo microbus',
                  subtitle: 'Registra una unidad con sus datos operativos basicos para dejarla disponible en tu cuenta.',
                  trailing: FaIcon(FontAwesomeIcons.busSimple, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 18),
                SectionCard(
                  child: Column(
                    children: [
                      TextField(controller: _plate, decoration: const InputDecoration(labelText: 'Placa', prefixIcon: Icon(Icons.pin_outlined))),
                      const SizedBox(height: 12),
                      TextField(controller: _model, decoration: const InputDecoration(labelText: 'Modelo', prefixIcon: Icon(Icons.directions_bus_outlined))),
                      const SizedBox(height: 12),
                      TextField(controller: _seats, decoration: const InputDecoration(labelText: 'Asientos', prefixIcon: Icon(Icons.event_seat_outlined))),
                      const SizedBox(height: 12),
                      TextField(controller: _internal, decoration: const InputDecoration(labelText: 'Numero interno', prefixIcon: Icon(Icons.confirmation_number_outlined))),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedLineId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Linea',
                          prefixIcon: Icon(Icons.route_outlined),
                        ),
                        items: _controller.lines
                            .map(
                              (line) => DropdownMenuItem<int>(
                                value: line.id,
                                child: Text(line.name),
                              ),
                            )
                            .toList(),
                        onChanged: _controller.isLoading
                            ? null
                            : (value) => setState(() => _selectedLineId = value),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _controller.isLoading
                      ? null
                      : (_selectedLineId == null)
                          ? null
                          : () async {
                              final ok = await _controller.registerBus(
                                plate: _plate.text.trim(),
                                model: _model.text.trim(),
                                seats: int.tryParse(_seats.text.trim()) ?? 20,
                                internalNumber: _internal.text.trim(),
                                lineId: _selectedLineId!,
                              );
                              if (ok && context.mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                  child: Text(_controller.isLoading ? 'Guardando...' : 'Registrar'),
                ),
                const SizedBox(height: 8),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo')),
                ],
              ),
            ),
          ),
        ),
      );
}

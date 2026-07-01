import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';
import '../../application/controllers/line_selection_controller.dart';

class ChangeLinePage extends StatefulWidget {
  const ChangeLinePage({super.key, this.onToggleTheme});

  final VoidCallback? onToggleTheme;

  @override
  State<ChangeLinePage> createState() => _ChangeLinePageState();
}

class _ChangeLinePageState extends State<ChangeLinePage> {
  final _controller = LineSelectionController();
  final _lineController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Cambiar linea',
        onToggleTheme: widget.onToggleTheme,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => ListView(
              children: [
                const DriverHeroCard(
                  title: 'Cambio operativo',
                  subtitle: 'Usa este cambio cuando la unidad pase a otra linea operativa. El backend dejara trazabilidad del ajuste.',
                  trailing: FaIcon(FontAwesomeIcons.route, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 18),
                SectionCard(
                  child: TextField(
                    controller: _lineController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva linea ID',
                      prefixIcon: Icon(Icons.alt_route_rounded),
                    ),
                  ),
                ),
                ElevatedButton(onPressed: () => _controller.changeLine(_lineController.text.trim()), child: const Text('Actualizar linea')),
                const SizedBox(height: 8),
                StatusBanner(text: _controller.status, isError: _controller.status.contains('No se pudo') || _controller.status.contains('Selecciona')),
              ],
            ),
          ),
        ),
      );
}

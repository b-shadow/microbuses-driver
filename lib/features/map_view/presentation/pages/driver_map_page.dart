import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_ui.dart';

class DriverMapPage extends StatelessWidget {
  const DriverMapPage({super.key, this.onToggleTheme});

  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    const center = LatLng(-17.7833, -63.1821);
    return AppShell(
      title: 'Mapa conductor',
      onToggleTheme: onToggleTheme,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        child: Column(
          children: [
            const DriverHeroCard(
              title: 'Mapa operativo',
              subtitle: 'Referencia visual de la zona actual para apoyar la conducción y el seguimiento básico del recorrido.',
              trailing: FaIcon(FontAwesomeIcons.mapLocationDot, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: FlutterMap(
                  options: const MapOptions(initialCenter: center, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'sig.microbuses.driver',
                    ),
                    const MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 48,
                          height: 48,
                          child: Icon(Icons.directions_bus, color: Colors.green, size: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

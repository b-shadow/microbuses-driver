import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/trip_start/presentation/pages/start_trip_page.dart';

void main() {
  testWidgets('renders start trip form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: StartTripPage(autoLoad: false, showMap: false)));

    expect(find.text('Gestionar recorrido'), findsOneWidget);
    expect(find.text('Preparacion de jornada'), findsOneWidget);
    expect(find.text('Selecciona con que microbus saldras'), findsOneWidget);
    expect(find.textContaining('Sin microbuses disponibles'), findsOneWidget);
  });
}

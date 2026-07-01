import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/active_trip/presentation/pages/active_trip_page.dart';

void main() {
  testWidgets('renders active trip screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ActiveTripPage(autoLoad: false, showMap: false)));

    expect(find.text('Viaje activo'), findsOneWidget);
    expect(find.text('Seguimiento en curso'), findsOneWidget);
    expect(find.text('Enviar ahora'), findsOneWidget);
  });
}

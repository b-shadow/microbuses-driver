import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/trip_finish/presentation/pages/finish_trip_page.dart';

void main() {
  testWidgets('renders finish trip actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinishTripPage(showMap: false)));

    expect(find.text('Finalizar recorrido'), findsOneWidget);
    expect(find.text('Confirmar finalizacion'), findsOneWidget);
  });
}

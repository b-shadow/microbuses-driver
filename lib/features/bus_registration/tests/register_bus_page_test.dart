import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/bus_registration/presentation/pages/register_bus_page.dart';

void main() {
  testWidgets('renders bus registration form', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterBusPage(autoLoad: false)));
    expect(find.text('Registrar microbus'), findsOneWidget);
    expect(find.text('Registrar'), findsOneWidget);
    expect(find.text('Linea'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/bus_assignment/presentation/pages/select_bus_page.dart';

void main() {
  testWidgets('renders select bus page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SelectBusPage(autoLoad: false)));
    expect(find.text('Seleccionar microbus'), findsOneWidget);
  });
}

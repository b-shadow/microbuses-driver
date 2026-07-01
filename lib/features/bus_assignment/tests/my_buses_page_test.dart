import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/bus_assignment/presentation/pages/my_buses_page.dart';

void main() {
  testWidgets('renders my buses page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MyBusesPage(autoLoad: false)));
    expect(find.text('Buses'), findsOneWidget);
    expect(find.text('Agregar bus'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/trip_start/presentation/pages/home_page.dart';

void main() {
  testWidgets('renders driver home shortcuts', (tester) async {
    await tester.pumpWidget(MaterialApp(home: DriverHomePage(onToggleTheme: () {})));

    expect(find.text('Panel conductor'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Buses'), findsOneWidget);
    expect(find.text('Gestionar recorrido'), findsOneWidget);
  });
}

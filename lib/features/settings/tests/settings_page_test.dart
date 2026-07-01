import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/settings/presentation/pages/settings_page.dart';

void main() {
  testWidgets('renders settings page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DriverSettingsPage()));
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Cerrar sesion'), findsOneWidget);
  });
}

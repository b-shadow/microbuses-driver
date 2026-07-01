import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/auth/presentation/pages/register_page.dart';

void main() {
  testWidgets('renders driver register screen controls', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DriverRegisterPage()));

    expect(find.text('Registro conductor'), findsOneWidget);
    expect(find.text('Solicitar acceso'), findsOneWidget);
    expect(find.text('Inicia sesion'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
  });
}

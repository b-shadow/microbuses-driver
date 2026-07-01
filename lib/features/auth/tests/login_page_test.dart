import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('renders driver login screen controls', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DriverLoginPage()));

    expect(find.text('Login conductor'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Ingresar'), findsOneWidget);
    expect(find.text('Registrate'), findsOneWidget);
  });
}

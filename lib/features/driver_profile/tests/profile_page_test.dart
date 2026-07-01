import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/driver_profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('renders driver profile page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DriverProfilePage(autoLoad: false)));
    expect(find.text('Perfil conductor'), findsOneWidget);
  });
}

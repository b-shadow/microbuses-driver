import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/line_selection/presentation/pages/change_line_page.dart';

void main() {
  testWidgets('renders change line page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChangeLinePage()));
    expect(find.text('Cambiar linea'), findsOneWidget);
    expect(find.text('Actualizar linea'), findsOneWidget);
  });
}

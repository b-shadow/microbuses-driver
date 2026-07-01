import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/features/audit_view/presentation/pages/audit_page.dart';

void main() {
  testWidgets('renders audit page', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuditPage(autoLoad: false)));
    expect(find.text('Auditoria'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_driver/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Microbuses driver app starts', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MicrobusesDriverApp());
    await tester.pump();

    expect(find.text('SIG Driver'), findsWidgets);
  });
}

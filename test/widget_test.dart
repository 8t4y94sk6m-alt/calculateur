import 'package:flutter_test/flutter_test.dart';

import 'package:calculateur/main.dart';

void main() {
  testWidgets('Smoke test Calculateur de Poutre', (WidgetTester tester) async {
    await tester.pumpWidget(const ApplicationPoutreApp());
    expect(find.text('Calculateur Poutre Symétrique'), findsOneWidget);
  });
}

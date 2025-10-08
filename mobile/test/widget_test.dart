import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Shows Login screen on start', (tester) async {
    // Pump the app
    await tester.pumpWidget(const AbsenkuApp());
    await tester.pumpAndSettle();

    // Expect Login screen elements
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}

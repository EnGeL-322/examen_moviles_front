import 'package:flutter_test/flutter_test.dart';
import 'package:sales/main.dart';

void main() {
  testWidgets('Main screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sistema de Ventas'), findsWidgets);
    expect(find.text('Bienvenido al Sistema de Ventas'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finora/app.dart';
import 'package:finora/providers/finance_store.dart';

void main() {
  testWidgets('App loads onboarding or main shell', (WidgetTester tester) async {
    final store = FinanceStore();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: const FinoraApp(),
      ),
    );

    expect(find.text('finora'), findsWidgets);
  });
}


import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cyberpulse_store/main.dart';
import 'package:cyberpulse_store/providers/store_provider.dart';

void main() {
  testWidgets('CyberPulse app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => StoreProvider(),
        child: const CyberPulseApp(),
      ),
    );

    expect(find.byType(CyberPulseApp), findsOneWidget);
  });
}

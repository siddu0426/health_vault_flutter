import 'package:flutter_test/flutter_test.dart';
import 'package:health_vault_flutter/main.dart';
import 'package:health_vault_flutter/voice_assistant.dart';

void main() {
  testWidgets('opens the health vault from the home dashboard', (tester) async {
    await tester.pumpWidget(const HealthVaultApp());
    expect(find.text('Good morning,'), findsOneWidget);

    await tester.tap(find.text('View Vault'));
    await tester.pumpAndSettle();

    expect(find.text('Health Vault'), findsOneWidget);
    expect(find.textContaining('Records Found'), findsOneWidget);
  });

  test('assistant routes medication requests', () {
    final reply = HealthAssistantEngine().reply('What medicine do I take tonight?');
    expect(reply.destination, 'medications');
    expect(reply.text, contains('8:00 PM'));
  });

  test('assistant includes an emergency safety instruction', () {
    final reply = HealthAssistantEngine().reply('Show emergency info');
    expect(reply.destination, 'emergency');
    expect(reply.text, contains('emergency services'));
  });
}

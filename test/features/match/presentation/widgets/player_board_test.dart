import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/widgets/player_board.dart';

void main() {
  const tPlayer = Player(
    id: 'player_1',
    life: 40,
    poisonCounters: 2,
    commanderDamageTaken: {'player_2': 5},
  );

  Widget createWidgetUnderTest({
    required Function(int) onLifeChanged,
    required Function(int) onPoisonChanged,
    required Function(int) onCommanderDamageChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PlayerBoard(
          player: tPlayer,
          backgroundColor: Colors.blue,
          onLifeChanged: onLifeChanged,
          onPoisonChanged: onPoisonChanged,
          onCommanderDamageChanged: onCommanderDamageChanged,
        ),
      ),
    );
  }

  group('PlayerBoard Widget |', () {
    testWidgets('should render player life and extra counters correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          onLifeChanged: (_) {},
          onPoisonChanged: (_) {},
          onCommanderDamageChanged: (_) {},
        ),
      );

      // Verifica se a vida 40 está na tela
      expect(find.text('40'), findsOneWidget);
      // Verifica se o dano de comandante (5) e veneno (2) aparecem nos badges
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets(
      'should call onLifeChanged with correct values on tap and long press',
      (tester) async {
        int? registeredAmount;

        await tester.pumpWidget(
          createWidgetUnderTest(
            onLifeChanged: (amount) => registeredAmount = amount,
            onPoisonChanged: (_) {},
            onCommanderDamageChanged: (_) {},
          ),
        );

        // Os GestureDetectors estão divididos na tela.
        // Pegamos o primeiro (metade de cima) e o segundo (metade de baixo).
        final gestureDetectors = find.byType(GestureDetector);

        // 1. Testa clique simples para somar 1 de vida (Metade de cima)
        await tester.tap(gestureDetectors.first);
        expect(registeredAmount, equals(1));

        // 2. Testa clique longo para somar 10 de vida (Metade de cima)
        await tester.longPress(gestureDetectors.first);
        expect(registeredAmount, equals(10));

        // 3. Testa clique simples para subtrair 1 de vida (Metade de baixo)
        await tester.tap(gestureDetectors.at(1));
        expect(registeredAmount, equals(-1));

        // 4. Testa clique longo para subtrair 10 de vida (Metade de baixo)
        await tester.longPress(gestureDetectors.at(1));
        expect(registeredAmount, equals(-10));
      },
    );
  });
}

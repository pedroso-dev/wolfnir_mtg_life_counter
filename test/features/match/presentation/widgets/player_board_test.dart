import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/enums/game_format.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_cubit.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_state.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/widgets/player_board.dart';

class MockMatchCubit extends Mock implements MatchCubit {}

void main() {
  late MockMatchCubit mockCubit;

  setUp(() {
    mockCubit = MockMatchCubit();
    when(() => mockCubit.state).thenReturn(
      const MatchState(
        players: {},
        status: MatchStatus.playing,
        format: GameFormat.commander,
      ),
    );
  });

  const tPlayer = Player(
    id: 'player_1',
    life: 40,
    poisonCounters: 2,
    commanderDamageTaken: {'player_2': 5},
  );

  Widget createWidgetUnderTest({
    required Function(int) onLifeChanged,
    required Function(int) onPoisonChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<MatchCubit>.value(
          value: mockCubit,
          child: PlayerBoard(
            player: tPlayer,
            backgroundColor: Colors.blue,
            showCommanderDamage: true,
            onLifeChanged: onLifeChanged,
            onPoisonChanged: onPoisonChanged,
          ),
        ),
      ),
    );
  }

  group('PlayerBoard Widget |', () {
    testWidgets('should render player life and extra counters correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(onLifeChanged: (_) {}, onPoisonChanged: (_) {}),
      );

      expect(find.text('40'), findsOneWidget);
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
          ),
        );

        final gestureDetectors = find.byType(GestureDetector);

        await tester.tap(gestureDetectors.first);
        expect(registeredAmount, equals(1));

        await tester.longPress(gestureDetectors.first);
        expect(registeredAmount, equals(10));

        await tester.tap(gestureDetectors.at(1));
        expect(registeredAmount, equals(-1));

        await tester.longPress(gestureDetectors.at(1));
        expect(registeredAmount, equals(-10));
      },
    );
  });
}

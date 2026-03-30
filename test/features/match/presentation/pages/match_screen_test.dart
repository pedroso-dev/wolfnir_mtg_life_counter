import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_cubit.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_state.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/pages/match_screen.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/widgets/player_board.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/enums/game_format.dart';
import 'package:wolfnir_mtg_life_counter/core/constants/strings.dart';

class MockMatchCubit extends MockCubit<MatchState> implements MatchCubit {}

void main() {
  late MockMatchCubit mockCubit;

  setUp(() {
    mockCubit = MockMatchCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<MatchCubit>.value(
        value: mockCubit,
        child: const MatchScreen(),
      ),
    );
  }

  group('MatchScreen Widget |', () {
    testWidgets(
      'should navigate setup screens and call startMatch on the Cubit',
      (tester) async {
        when(() => mockCubit.state).thenReturn(
          const MatchState(players: {}, status: MatchStatus.initial),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text(AppStrings.selectFormat), findsOneWidget);
        expect(find.text(AppStrings.commander), findsOneWidget);

        await tester.tap(find.text(AppStrings.commander));
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.selectPlayers), findsOneWidget);
        expect(find.text(AppStrings.fourPlayers), findsOneWidget);

        await tester.tap(find.text(AppStrings.fourPlayers));
        await tester.pump();
      },
    );

    testWidgets(
      'should render 2 PlayerBoards and middle bar when playing 1v1',
      (tester) async {
        const p1 = Player(id: 'player_1', life: 40);
        const p2 = Player(id: 'player_2', life: 40);

        when(() => mockCubit.state).thenReturn(
          const MatchState(
            players: {'player_1': p1, 'player_2': p2},
            status: MatchStatus.playing,
            format: GameFormat.commander,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(PlayerBoard), findsNWidgets(2));
        expect(find.byIcon(Icons.casino), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      },
    );

    testWidgets('should render 3 PlayerBoards when playing a 3-player match', (
      tester,
    ) async {
      const p1 = Player(id: 'player_1', life: 40);
      const p2 = Player(id: 'player_2', life: 40);
      const p3 = Player(id: 'player_3', life: 40);

      when(() => mockCubit.state).thenReturn(
        const MatchState(
          players: {'player_1': p1, 'player_2': p2, 'player_3': p3},
          status: MatchStatus.playing,
          format: GameFormat.commander,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(PlayerBoard), findsNWidgets(3));
    });

    testWidgets('should render 4 PlayerBoards when playing a 4-player match', (
      tester,
    ) async {
      const p1 = Player(id: 'player_1', life: 40);
      const p2 = Player(id: 'player_2', life: 40);
      const p3 = Player(id: 'player_3', life: 40);
      const p4 = Player(id: 'player_4', life: 40);

      when(() => mockCubit.state).thenReturn(
        const MatchState(
          players: {
            'player_1': p1,
            'player_2': p2,
            'player_3': p3,
            'player_4': p4,
          },
          status: MatchStatus.playing,
          format: GameFormat.commander,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(PlayerBoard), findsNWidgets(4));
    });
  });
}

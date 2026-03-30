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
    testWidgets('should show loading indicator when state is initial', (
      tester,
    ) async {
      when(
        () => mockCubit.state,
      ).thenReturn(const MatchState(players: {}, status: MatchStatus.initial));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render 2 PlayerBoards and middle bar when playing', (
      tester,
    ) async {
      const p1 = Player(id: 'player_1', life: 40);
      const p2 = Player(id: 'player_2', life: 40);

      when(() => mockCubit.state).thenReturn(
        const MatchState(
          players: {'player_1': p1, 'player_2': p2},
          status: MatchStatus.playing,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica se os dois tabuleiros foram desenhados na tela
      expect(find.byType(PlayerBoard), findsNWidgets(2));

      // Verifica se os ícones da barra central (Dado e Reset) estão na tela
      expect(find.byIcon(Icons.casino), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}

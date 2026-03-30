import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/enums/game_format.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_commander_damage_usecase.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_life_usecase.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_poison_usecase.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_cubit.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_state.dart';

class MockUpdateLifeUseCase extends Mock implements UpdateLifeUseCase {}

class MockUpdatePoisonUseCase extends Mock implements UpdatePoisonUseCase {}

class MockUpdateCommanderDamageUseCase extends Mock
    implements UpdateCommanderDamageUseCase {}

class FakePlayer extends Fake implements Player {}

void main() {
  late MatchCubit cubit;
  late MockUpdateLifeUseCase mockUpdateLife;
  late MockUpdatePoisonUseCase mockUpdatePoison;
  late MockUpdateCommanderDamageUseCase mockUpdateCommanderDamage;

  setUpAll(() {
    registerFallbackValue(FakePlayer());
  });

  setUp(() {
    mockUpdateLife = MockUpdateLifeUseCase();
    mockUpdatePoison = MockUpdatePoisonUseCase();
    mockUpdateCommanderDamage = MockUpdateCommanderDamageUseCase();

    cubit = MatchCubit(
      updateLife: mockUpdateLife,
      updatePoison: mockUpdatePoison,
      updateCommanderDamage: mockUpdateCommanderDamage,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('MatchCubit |', () {
    // Agora informamos a vida inicial 40 para simular o formato Commander
    const player1 = Player(id: 'player_1', life: 40);
    const player2 = Player(id: 'player_2', life: 40);

    test('initial state should be MatchStatus.initial with empty players', () {
      expect(cubit.state.status, equals(MatchStatus.initial));
      expect(cubit.state.players, isEmpty);
      expect(cubit.state.format, isNull);
    });

    blocTest<MatchCubit, MatchState>(
      'should emit playing status, set format and initialize players when startMatch is called',
      build: () => cubit,
      act: (cubit) => cubit.startMatch(GameFormat.commander),
      expect: () => [
        const MatchState(
          players: {'player_1': player1, 'player_2': player2},
          status: MatchStatus.playing,
          format: GameFormat.commander,
        ),
      ],
    );

    blocTest<MatchCubit, MatchState>(
      'should update player life and emit new state when updateLife is called',
      build: () {
        const updatedPlayer = Player(id: 'player_1', life: 39);
        when(
          () => mockUpdateLife(player: any(named: 'player'), amount: -1),
        ).thenReturn(updatedPlayer);
        return cubit;
      },
      seed: () => const MatchState(
        players: {'player_1': player1, 'player_2': player2},
        status: MatchStatus.playing,
        format: GameFormat.commander,
      ),
      act: (cubit) => cubit.updateLife('player_1', -1),
      expect: () => [
        const MatchState(
          players: {
            'player_1': Player(id: 'player_1', life: 39),
            'player_2': player2,
          },
          status: MatchStatus.playing,
          format: GameFormat.commander,
        ),
      ],
    );

    blocTest<MatchCubit, MatchState>(
      'should emit finished status and loserId when a player dies',
      build: () {
        const deadPlayer = Player(id: 'player_1', life: 0);
        when(
          () => mockUpdateLife(player: any(named: 'player'), amount: -40),
        ).thenReturn(deadPlayer);
        return cubit;
      },
      seed: () => const MatchState(
        players: {'player_1': player1, 'player_2': player2},
        status: MatchStatus.playing,
        format: GameFormat.commander,
      ),
      act: (cubit) => cubit.updateLife('player_1', -40),
      expect: () => [
        const MatchState(
          players: {
            'player_1': Player(id: 'player_1', life: 0),
            'player_2': player2,
          },
          status: MatchStatus.finished,
          loserId: 'player_1',
          format: GameFormat.commander,
        ),
      ],
    );

    blocTest<MatchCubit, MatchState>(
      'should return to initial state when changeFormat is called',
      build: () => cubit,
      seed: () => const MatchState(
        players: {'player_1': player1, 'player_2': player2},
        status: MatchStatus.playing,
        format: GameFormat.commander,
      ),
      act: (cubit) => cubit.changeFormat(),
      expect: () => [
        const MatchState(players: {}, status: MatchStatus.initial),
      ],
    );
  });
}

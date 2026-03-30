import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_commander_damage_usecase.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_life_usecase.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_poison_usecase.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_cubit.dart';
import 'package:wolfnir_mtg_life_counter/features/match/presentation/cubit/match_state.dart';

// 1. Creating the Mocks
class MockUpdateLifeUseCase extends Mock implements UpdateLifeUseCase {}

class MockUpdatePoisonUseCase extends Mock implements UpdatePoisonUseCase {}

class MockUpdateCommanderDamageUseCase extends Mock
    implements UpdateCommanderDamageUseCase {}

// We need a fallback value for the Player entity so mocktail knows how to handle it in generic calls
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
    const player1 = Player(id: 'player_1');
    const player2 = Player(id: 'player_2');

    test('initial state should be MatchStatus.initial with empty players', () {
      expect(cubit.state.status, equals(MatchStatus.initial));
      expect(cubit.state.players, isEmpty);
    });

    blocTest<MatchCubit, MatchState>(
      'should emit playing status and initialize 2 players when startMatch is called',
      build: () => cubit,
      act: (cubit) => cubit.startMatch(),
      expect: () => [
        const MatchState(
          players: {'player_1': player1, 'player_2': player2},
          status: MatchStatus.playing,
        ),
      ],
    );

    blocTest<MatchCubit, MatchState>(
      'should update player life and emit new state when updateLife is called',
      build: () {
        // Arrange
        const updatedPlayer = Player(id: 'player_1', life: 39);
        when(
          () => mockUpdateLife(player: any(named: 'player'), amount: -1),
        ).thenReturn(updatedPlayer);
        return cubit;
      },
      seed: () => const MatchState(
        players: {'player_1': player1, 'player_2': player2},
        status: MatchStatus.playing,
      ),
      act: (cubit) => cubit.updateLife('player_1', -1),
      expect: () => [
        const MatchState(
          players: {
            'player_1': Player(id: 'player_1', life: 39),
            'player_2': player2,
          },
          status: MatchStatus.playing,
        ),
      ],
      verify: (_) {
        verify(() => mockUpdateLife(player: player1, amount: -1)).called(1);
      },
    );

    blocTest<MatchCubit, MatchState>(
      'should emit finished status and loserId when a player dies',
      build: () {
        // Arrange: Player 1 life drops to 0
        const deadPlayer = Player(id: 'player_1', life: 0);
        when(
          () => mockUpdateLife(player: any(named: 'player'), amount: -40),
        ).thenReturn(deadPlayer);
        return cubit;
      },
      seed: () => const MatchState(
        players: {'player_1': player1, 'player_2': player2},
        status: MatchStatus.playing,
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
        ),
      ],
    );
  });
}

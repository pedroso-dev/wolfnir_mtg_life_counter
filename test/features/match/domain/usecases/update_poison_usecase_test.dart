import 'package:flutter_test/flutter_test.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_poison_usecase.dart';

void main() {
  late UpdatePoisonUseCase usecase;

  setUp(() {
    usecase = UpdatePoisonUseCase();
  });

  group('UpdatePoisonUseCase |', () {
    test('should add poison counters correctly', () {
      const player = Player(id: 'p1', poisonCounters: 0);
      final result = usecase(player: player, amount: 2);
      expect(result.poisonCounters, equals(2));
    });

    test('should not allow poison counters to be less than 0', () {
      const player = Player(id: 'p1', poisonCounters: 1);
      // Tentando remover 3 venenos de quem só tem 1
      final result = usecase(player: player, amount: -3);
      expect(result.poisonCounters, equals(0));
    });
  });
}

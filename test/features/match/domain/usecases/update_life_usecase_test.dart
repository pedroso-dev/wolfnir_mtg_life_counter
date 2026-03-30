import 'package:flutter_test/flutter_test.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_life_usecase.dart';

void main() {
  late UpdateLifeUseCase usecase;

  setUp(() {
    usecase = UpdateLifeUseCase();
  });

  group('UpdateLifeUseCase |', () {
    test('should increase player life by the given amount', () {
      const player = Player(id: 'p1', life: 40);
      final result = usecase(player: player, amount: 5);
      expect(result.life, equals(45));
    });

    test('should decrease player life by the given amount', () {
      const player = Player(id: 'p1', life: 40);
      final result = usecase(player: player, amount: -3);
      expect(result.life, equals(37));
    });
  });
}

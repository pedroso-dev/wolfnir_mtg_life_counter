import 'package:flutter_test/flutter_test.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';

void main() {
  group('Player Entity |', () {
    test(
      'should have isDead as false when initialized with default Commander values',
      () {
        const player = Player(id: 'p1');

        expect(player.life, equals(40));
        expect(player.poisonCounters, equals(0));
        expect(player.commanderDamageTaken, isEmpty);
        expect(player.isDead, isFalse);
      },
    );

    test('should return isDead true when life is 0 or less', () {
      const playerDeadExact = Player(id: 'p1', life: 0);
      const playerDeadNegative = Player(id: 'p1', life: -5);

      expect(playerDeadExact.isDead, isTrue);
      expect(playerDeadNegative.isDead, isTrue);
    });

    test('should return isDead true when poison counters are 10 or more', () {
      const playerDeadExact = Player(id: 'p1', poisonCounters: 10);
      const playerDeadOver = Player(id: 'p1', poisonCounters: 15);

      expect(playerDeadExact.isDead, isTrue);
      expect(playerDeadOver.isDead, isTrue);
    });

    test(
      'should return isDead true when taking 21 or more damage from a SINGLE opponent commander',
      () {
        const player = Player(
          id: 'p1',
          commanderDamageTaken: {'opponent_1': 21, 'opponent_2': 5},
        );

        expect(player.isDead, isTrue);
      },
    );

    test(
      'should return isDead false when taking 20 damage from multiple commanders but not 21 from a single one',
      () {
        const player = Player(
          id: 'p1',
          commanderDamageTaken: {'opponent_1': 20, 'opponent_2': 20},
        );

        expect(player.isDead, isFalse);
      },
    );

    test('should maintain immutability and update correctly via copyWith', () {
      const player = Player(id: 'p1');

      final updatedPlayer = player.copyWith(
        life: 35,
        poisonCounters: 2,
        commanderDamageTaken: {'opponent_1': 5},
      );

      expect(updatedPlayer.life, equals(35));
      expect(updatedPlayer.poisonCounters, equals(2));
      expect(updatedPlayer.commanderDamageTaken, equals({'opponent_1': 5}));

      expect(player.life, equals(40));
      expect(player.commanderDamageTaken, isEmpty);
    });
  });
}

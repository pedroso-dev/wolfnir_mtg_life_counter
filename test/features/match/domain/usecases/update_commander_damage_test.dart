import 'package:flutter_test/flutter_test.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/usecases/update_commander_damage_usecase.dart';

void main() {
  late UpdateCommanderDamageUseCase usecase;

  setUp(() {
    usecase = UpdateCommanderDamageUseCase();
  });

  group('UpdateCommanderDamageUseCase |', () {
    test(
      'should add commander damage and reduce total life simultaneously',
      () {
        const player = Player(id: 'p1', life: 40, commanderDamageTaken: {});

        final result = usecase(player: player, opponentId: 'p2', amount: 5);

        expect(result.commanderDamageTaken['p2'], equals(5));
        expect(result.life, equals(35)); // 40 - 5
      },
    );

    test(
      'should remove commander damage and restore total life (correcting mistakes)',
      () {
        const player = Player(
          id: 'p1',
          life: 35,
          commanderDamageTaken: {'p2': 5},
        );

        final result = usecase(player: player, opponentId: 'p2', amount: -2);

        expect(result.commanderDamageTaken['p2'], equals(3));
        expect(result.life, equals(37)); // Restaurou 2 de vida
      },
    );

    test(
      'should not allow commander damage below 0, and should not restore life if damage was already 0',
      () {
        const player = Player(
          id: 'p1',
          life: 40,
          commanderDamageTaken: {'p2': 0},
        );

        // Tentando remover dano de comandante que não existe
        final result = usecase(player: player, opponentId: 'p2', amount: -5);

        expect(result.commanderDamageTaken['p2'], equals(0));
        expect(
          result.life,
          equals(40),
        ); // Vida não pode subir se não havia dano de comandante para remover
      },
    );
  });
}

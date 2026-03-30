import '../entities/player.dart';
import '../enums/game_format.dart';

class UpdateCommanderDamageUseCase {
  Player call({
    required Player player,
    required String opponentId,
    required int amount,
    GameFormat? format,
  }) {
    if (format != null && !format.hasCommanderDamage) {
      return player;
    }

    final currentDamage = player.commanderDamageTaken[opponentId] ?? 0;
    final newDamage = currentDamage + amount;

    final clampedDamage = newDamage < 0 ? 0 : newDamage;

    final Map<String, int> updatedDamageMap = Map.of(
      player.commanderDamageTaken,
    );
    updatedDamageMap[opponentId] = clampedDamage;

    final lifeImpact = currentDamage == 0 && amount < 0 ? 0 : amount;
    final newLife = player.life - lifeImpact;

    return player.copyWith(
      commanderDamageTaken: updatedDamageMap,
      life: newLife,
    );
  }
}

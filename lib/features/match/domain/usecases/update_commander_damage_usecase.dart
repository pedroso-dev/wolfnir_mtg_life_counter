import '../entities/player.dart';

class UpdateCommanderDamageUseCase {
  Player call({
    required Player player,
    required String opponentId,
    required int amount,
  }) {
    final currentDamage = player.commanderDamageTaken[opponentId] ?? 0;
    final newDamage = currentDamage + amount;

    // Commander damage cannot be negative
    final clampedDamage = newDamage < 0 ? 0 : newDamage;

    final Map<String, int> updatedDamageMap = Map.of(
      player.commanderDamageTaken,
    );
    updatedDamageMap[opponentId] = clampedDamage;

    // MTG Rule: Taking commander damage also reduces total life.
    // If we are correcting a mistake (amount < 0), we restore life,
    // but we shouldn't restore life if the commander damage was already 0.
    final lifeImpact = currentDamage == 0 && amount < 0 ? 0 : amount;
    final newLife = player.life - lifeImpact;

    return player.copyWith(
      commanderDamageTaken: updatedDamageMap,
      life: newLife,
    );
  }
}

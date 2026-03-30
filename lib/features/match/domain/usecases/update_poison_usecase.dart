import '../entities/player.dart';

class UpdatePoisonUseCase {
  Player call({required Player player, required int amount}) {
    final newPoison = player.poisonCounters + amount;

    // Poison counters cannot be negative
    final clampedPoison = newPoison < 0 ? 0 : newPoison;

    return player.copyWith(poisonCounters: clampedPoison);
  }
}

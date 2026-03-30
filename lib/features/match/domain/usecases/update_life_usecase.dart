import '../entities/player.dart';

class UpdateLifeUseCase {
  Player call({required Player player, required int amount}) {
    return player.copyWith(life: player.life + amount);
  }
}

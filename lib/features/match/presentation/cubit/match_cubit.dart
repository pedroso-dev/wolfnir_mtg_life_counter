import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/enums/game_format.dart';
import '../../domain/entities/player.dart';
import '../../domain/usecases/update_life_usecase.dart';
import '../../domain/usecases/update_poison_usecase.dart';
import '../../domain/usecases/update_commander_damage_usecase.dart';
import 'match_state.dart';

class MatchCubit extends Cubit<MatchState> {
  final UpdateLifeUseCase _updateLife;
  final UpdatePoisonUseCase _updatePoison;
  final UpdateCommanderDamageUseCase _updateCommanderDamage;

  MatchCubit({
    required UpdateLifeUseCase updateLife,
    required UpdatePoisonUseCase updatePoison,
    required UpdateCommanderDamageUseCase updateCommanderDamage,
  }) : _updateLife = updateLife,
       _updatePoison = updatePoison,
       _updateCommanderDamage = updateCommanderDamage,
       super(const MatchState(players: {}));

  void startMatch(GameFormat format) {
    // For the MVP, we start a standard 1v1 Commander match
    final p1 = Player(id: 'player_1', life: format.startingLife);
    final p2 = Player(id: 'player_2', life: format.startingLife);

    emit(
      MatchState(
        players: {'player_1': p1, 'player_2': p2},
        status: MatchStatus.playing,
        format: format,
      ),
    );
  }

  void updateLife(String playerId, int amount) {
    if (state.status != MatchStatus.playing) return;

    final player = state.players[playerId];
    if (player != null) {
      final updatedPlayer = _updateLife(player: player, amount: amount);
      _emitUpdatedPlayer(updatedPlayer);
    }
  }

  void updatePoison(String playerId, int amount) {
    if (state.status != MatchStatus.playing) return;

    final player = state.players[playerId];
    if (player != null) {
      final updatedPlayer = _updatePoison(player: player, amount: amount);
      _emitUpdatedPlayer(updatedPlayer);
    }
  }

  void updateCommanderDamage({
    required String targetPlayerId,
    required String opponentId,
    required int amount,
  }) {
    if (state.status != MatchStatus.playing) return;

    final player = state.players[targetPlayerId];
    if (player != null) {
      final updatedPlayer = _updateCommanderDamage(
        player: player,
        opponentId: opponentId,
        amount: amount,
      );
      _emitUpdatedPlayer(updatedPlayer);
    }
  }

  void resetMatch() {
    if (state.format != null) {
      startMatch(state.format!);
    }
  }

  void changeFormat() {
    emit(const MatchState(players: {}));
  }

  void _emitUpdatedPlayer(Player updatedPlayer) {
    final newPlayers = Map<String, Player>.from(state.players);
    newPlayers[updatedPlayer.id] = updatedPlayer;

    // The Cubit checks the rules automatically after any update
    if (updatedPlayer.isDead) {
      emit(
        state.copyWith(
          players: newPlayers,
          status: MatchStatus.finished,
          loserId: updatedPlayer.id,
        ),
      );
    } else {
      emit(state.copyWith(players: newPlayers));
    }
  }
}

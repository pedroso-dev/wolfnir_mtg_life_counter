import 'package:equatable/equatable.dart';
import '../../domain/entities/player.dart';
import '../../domain/enums/game_format.dart';

enum MatchStatus { initial, playing, finished }

class MatchState extends Equatable {
  // Using a Map makes it very fast (O(1)) to find and update a specific player
  final Map<String, Player> players;
  final MatchStatus status;
  final String? loserId;
  final GameFormat? format; // Adicionado aqui

  const MatchState({
    required this.players,
    this.status = MatchStatus.initial,
    this.loserId,
    this.format, // Adicionado aqui
  });

  MatchState copyWith({
    Map<String, Player>? players,
    MatchStatus? status,
    String? loserId,
    GameFormat? format, // Adicionado aqui
  }) {
    return MatchState(
      players: players ?? this.players,
      status: status ?? this.status,
      loserId: loserId ?? this.loserId,
      format: format ?? this.format, // Adicionado aqui
    );
  }

  @override
  List<Object?> get props => [players, status, loserId, format];
}

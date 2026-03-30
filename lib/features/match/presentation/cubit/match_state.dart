import 'package:equatable/equatable.dart';
import '../../domain/entities/player.dart';
import '../../domain/enums/game_format.dart';

enum MatchStatus { initial, playing, finished }

class MatchState extends Equatable {
  final Map<String, Player> players;
  final MatchStatus status;
  final GameFormat? format;
  final String? winnerId;

  const MatchState({
    required this.players,
    this.status = MatchStatus.initial,
    this.format,
    this.winnerId,
  });

  MatchState copyWith({
    Map<String, Player>? players,
    MatchStatus? status,
    GameFormat? format,
    String? winnerId,
  }) {
    return MatchState(
      players: players ?? this.players,
      status: status ?? this.status,
      format: format ?? this.format,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  @override
  List<Object?> get props => [players, status, format, winnerId];
}

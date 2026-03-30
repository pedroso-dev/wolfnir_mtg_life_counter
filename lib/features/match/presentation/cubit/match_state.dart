import 'package:equatable/equatable.dart';
import '../../domain/entities/player.dart';

enum MatchStatus { initial, playing, finished }

class MatchState extends Equatable {
  // Using a Map makes it very fast (O(1)) to find and update a specific player
  final Map<String, Player> players;
  final MatchStatus status;
  final String? loserId;

  const MatchState({
    required this.players,
    this.status = MatchStatus.initial,
    this.loserId,
  });

  MatchState copyWith({
    Map<String, Player>? players,
    MatchStatus? status,
    String? loserId,
  }) {
    return MatchState(
      players: players ?? this.players,
      status: status ?? this.status,
      loserId: loserId ?? this.loserId,
    );
  }

  @override
  List<Object?> get props => [players, status, loserId];
}

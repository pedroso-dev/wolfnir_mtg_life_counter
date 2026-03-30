import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final int life;
  final int poisonCounters;
  final Map<String, int> commanderDamageTaken;

  const Player({
    required this.id,
    this.life = 40,
    this.poisonCounters = 0,
    this.commanderDamageTaken = const {},
  });

  bool get isDead {
    if (life <= 0) return true;
    if (poisonCounters >= 10) return true;

    if (commanderDamageTaken.values.any((damage) => damage >= 21)) {
      return true;
    }

    return false;
  }

  Player copyWith({
    String? id,
    int? life,
    int? poisonCounters,
    Map<String, int>? commanderDamageTaken,
  }) {
    return Player(
      id: id ?? this.id,
      life: life ?? this.life,
      poisonCounters: poisonCounters ?? this.poisonCounters,
      commanderDamageTaken:
          commanderDamageTaken ?? Map.unmodifiable(this.commanderDamageTaken),
    );
  }

  @override
  List<Object?> get props => [id, life, poisonCounters, commanderDamageTaken];
}

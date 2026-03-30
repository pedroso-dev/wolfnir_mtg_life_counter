import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/strings.dart';
import '../cubit/match_cubit.dart';
import '../cubit/match_state.dart';

class CommanderDamageModal extends StatelessWidget {
  final String targetPlayerId;

  const CommanderDamageModal({super.key, required this.targetPlayerId});

  Color _getOpponentColor(String id) {
    switch (id) {
      case 'player_1':
        return Colors.blue.shade400;
      case 'player_2':
        return Colors.red.shade400;
      case 'player_3':
        return Colors.green.shade400;
      case 'player_4':
        return Colors.deepPurple.shade400;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchCubit, MatchState>(
      builder: (context, state) {
        final targetPlayer = state.players[targetPlayerId];
        if (targetPlayer == null) return const SizedBox.shrink();

        final opponents = state.players.values
            .where((p) => p.id != targetPlayerId)
            .toList();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.commanderDamage,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              ...opponents.map((opponent) {
                final damage =
                    targetPlayer.commanderDamageTaken[opponent.id] ?? 0;
                final opColor = _getOpponentColor(opponent.id);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opponent.id.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: opColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: opColor,
                              size: 36,
                            ),
                            onPressed: () => context
                                .read<MatchCubit>()
                                .updateCommanderDamage(
                                  targetPlayerId: targetPlayerId,
                                  opponentId: opponent.id,
                                  amount: -1,
                                ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              damage.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: opColor,
                              size: 36,
                            ),
                            onPressed: () => context
                                .read<MatchCubit>()
                                .updateCommanderDamage(
                                  targetPlayerId: targetPlayerId,
                                  opponentId: opponent.id,
                                  amount: 1,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

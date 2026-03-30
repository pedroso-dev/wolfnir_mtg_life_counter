import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/strings.dart';
import '../cubit/match_cubit.dart';
import '../cubit/match_state.dart';
import '../widgets/player_board.dart';
import '../widgets/dice_modal.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  void initState() {
    super.initState();
    // Start the match when the screen loads
    context.read<MatchCubit>().startMatch();
  }

  void _showWinnerDialog(BuildContext context, String loserId) {
    final matchCubit = context.read<MatchCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.matchFinished),
        content: Text('$loserId ${AppStrings.playerLost}'),
        actions: [
          TextButton(
            onPressed: () {
              // Em vez de fechar só o alerta com .pop(), limpamos TUDO (Alerta e Modais)
              Navigator.of(context).popUntil((route) => route.isFirst);

              // E então reiniciamos a partida
              matchCubit.resetMatch();
            },
            child: const Text(AppStrings.resetMatch),
          ),
        ],
      ),
    );
  }

  void _showDiceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const DiceModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<MatchCubit, MatchState>(
        listener: (context, state) {
          if (state.status == MatchStatus.finished && state.loserId != null) {
            _showWinnerDialog(context, state.loserId!);
          }
        },
        builder: (context, state) {
          if (state.status == MatchStatus.initial || state.players.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final p1 = state.players['player_1']!;
          final p2 = state.players['player_2']!;

          return Column(
            children: [
              // Top Half: Player 2
              Expanded(
                child: PlayerBoard(
                  player: p2,
                  backgroundColor: Colors.red.shade800,
                  inverted: true,
                  onLifeChanged: (amount) =>
                      context.read<MatchCubit>().updateLife('player_2', amount),
                  onPoisonChanged: (amount) => context
                      .read<MatchCubit>()
                      .updatePoison('player_2', amount),
                  onCommanderDamageChanged: (amount) =>
                      context.read<MatchCubit>().updateCommanderDamage(
                        targetPlayerId: 'player_2',
                        opponentId: 'player_1',
                        amount: amount,
                      ),
                ),
              ),

              // Middle Bar: Reset / Menu
              Container(
                height: 60,
                color: Colors.grey.shade900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.casino,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => _showDiceModal(context),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                        context.read<MatchCubit>().resetMatch();
                      },
                    ),
                  ],
                ),
              ),

              // Bottom Half: Player 1
              Expanded(
                child: PlayerBoard(
                  player: p1,
                  backgroundColor: Colors.blue.shade800,
                  onLifeChanged: (amount) =>
                      context.read<MatchCubit>().updateLife('player_1', amount),
                  onPoisonChanged: (amount) => context
                      .read<MatchCubit>()
                      .updatePoison('player_1', amount),
                  onCommanderDamageChanged: (amount) =>
                      context.read<MatchCubit>().updateCommanderDamage(
                        targetPlayerId: 'player_1',
                        opponentId:
                            'player_2', // No 1v1, o oponente é sempre o 2
                        amount: amount,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

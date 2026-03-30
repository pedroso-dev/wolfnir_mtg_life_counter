import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/strings.dart';
import '../cubit/match_cubit.dart';
import '../cubit/match_state.dart';
import '../widgets/player_board.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.matchFinished),
        content: Text('$loserId ${AppStrings.playerLost}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MatchCubit>().resetMatch();
            },
            child: const Text(AppStrings.resetMatch),
          ),
        ],
      ),
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
                ),
              ),

              // Middle Bar: Reset / Menu
              Container(
                height: 60,
                color: Colors.grey.shade900,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => context.read<MatchCubit>().resetMatch(),
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

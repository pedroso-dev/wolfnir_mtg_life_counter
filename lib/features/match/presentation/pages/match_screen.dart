import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wolfnir_mtg_life_counter/features/match/domain/entities/player.dart';
import '../../../../core/constants/strings.dart';
import '../cubit/match_cubit.dart';
import '../cubit/match_state.dart';
import '../widgets/player_board.dart';
import '../widgets/dice_modal.dart';
import '../../domain/enums/game_format.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // Variável para guardar o formato enquanto o usuário escolhe a quantidade de jogadores
  GameFormat? _pendingFormat;

  @override
  void initState() {
    super.initState();
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
              Navigator.of(context).popUntil((route) => route.isFirst);
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

  // ... (mantenha os imports, initState, _showWinnerDialog e _showDiceModal)

  Widget _buildSetupScreen(BuildContext context) {
    // PASSO 1: Escolher o Formato
    if (_pendingFormat == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              AppStrings.selectFormat,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 48),
            _FormatButton(
              title: GameFormat.commander.displayName,
              color: Colors.purple.shade700,
              onPressed: () =>
                  setState(() => _pendingFormat = GameFormat.commander),
            ),
            const SizedBox(height: 16),
            _FormatButton(
              title: GameFormat.tinyLeaders.displayName,
              color: Colors.orange.shade700,
              onPressed: () =>
                  setState(() => _pendingFormat = GameFormat.tinyLeaders),
            ),
            const SizedBox(height: 16),
            _FormatButton(
              title: GameFormat.duelCommander.displayName,
              color: Colors.teal.shade700,
              onPressed: () =>
                  setState(() => _pendingFormat = GameFormat.duelCommander),
            ),
          ],
        ),
      );
    }

    // PASSO 2: Escolher Quantos Jogadores
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            AppStrings.selectPlayers,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          _FormatButton(
            title: AppStrings.twoPlayers,
            color: Colors.blueGrey.shade700,
            onPressed: () => context.read<MatchCubit>().startMatch(
              format: _pendingFormat!,
              playerCount: 2,
            ),
          ),
          const SizedBox(height: 16),
          _FormatButton(
            title: AppStrings.threePlayers,
            color: Colors.blueGrey.shade700,
            onPressed: () => context.read<MatchCubit>().startMatch(
              format: _pendingFormat!,
              playerCount: 3,
            ),
          ),
          const SizedBox(height: 16),
          _FormatButton(
            title: AppStrings.fourPlayers,
            color: Colors.blueGrey.shade700,
            onPressed: () => context.read<MatchCubit>().startMatch(
              format: _pendingFormat!,
              playerCount: 4,
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              AppStrings.back,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => setState(() => _pendingFormat = null),
          ),
        ],
      ),
    );
  }

  // --- NOVO: Método ajudante para desenhar os jogadores sem repetir código ---
  Widget _buildPlayer(Player player, Color color, {bool inverted = false}) {
    return Expanded(
      child: PlayerBoard(
        player: player,
        backgroundColor: color,
        inverted: inverted,
        showCommanderDamage:
            context.read<MatchCubit>().state.format?.hasCommanderDamage ??
            false,
        onLifeChanged: (amount) =>
            context.read<MatchCubit>().updateLife(player.id, amount),
        onPoisonChanged: (amount) =>
            context.read<MatchCubit>().updatePoison(player.id, amount),
      ),
    );
  }

  // --- NOVO: Barra central extraída para ficar mais limpo ---
  Widget _buildMiddleBar(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.style, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<MatchCubit>().changeFormat();
            },
          ),
          IconButton(
            icon: const Icon(Icons.casino, color: Colors.white, size: 30),
            onPressed: () => _showDiceModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.read<MatchCubit>().resetMatch();
            },
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
          if (state.status == MatchStatus.initial && _pendingFormat != null) {
            setState(() => _pendingFormat = null);
          }
          if (state.status == MatchStatus.finished && state.loserId != null) {
            _showWinnerDialog(context, state.loserId!);
          }
        },
        builder: (context, state) {
          if (state.status == MatchStatus.initial) {
            return _buildSetupScreen(context);
          }

          if (state.players.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final p1 = state.players['player_1'];
          final p2 = state.players['player_2'];
          final p3 = state.players['player_3'];
          final p4 = state.players['player_4'];

          if (p1 == null || p2 == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final playerCount = state.players.length;

          return Column(
            children: [
              // LINHA DE CIMA (Sempre invertida para quem está do outro lado da mesa)
              Expanded(
                child: Row(
                  children: [
                    if (playerCount == 2)
                      _buildPlayer(p2, Colors.red.shade800, inverted: true),
                    if (playerCount == 3) ...[
                      _buildPlayer(p2, Colors.red.shade800, inverted: true),
                      _buildPlayer(p3!, Colors.green.shade800, inverted: true),
                    ],
                    if (playerCount == 4) ...[
                      _buildPlayer(p3!, Colors.green.shade800, inverted: true),
                      _buildPlayer(
                        p4!,
                        Colors.deepPurple.shade800,
                        inverted: true,
                      ),
                    ],
                  ],
                ),
              ),

              // BARRA CENTRAL
              _buildMiddleBar(context),

              // LINHA DE BAIXO (De frente para o dono do celular)
              Expanded(
                child: Row(
                  children: [
                    if (playerCount == 2 || playerCount == 3)
                      _buildPlayer(p1, Colors.blue.shade800),
                    if (playerCount == 4) ...[
                      _buildPlayer(p1, Colors.blue.shade800),
                      _buildPlayer(p2, Colors.red.shade800),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

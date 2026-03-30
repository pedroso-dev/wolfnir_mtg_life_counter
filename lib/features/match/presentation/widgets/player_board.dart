import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../../../core/constants/strings.dart';
import 'counter_modal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/match_cubit.dart';
import '../cubit/match_state.dart';
import 'commander_damage_modal.dart';

class PlayerBoard extends StatelessWidget {
  final Player player;
  final Color backgroundColor;
  final bool inverted;
  final bool showCommanderDamage;
  final Function(int) onLifeChanged;
  final Function(int) onPoisonChanged;

  const PlayerBoard({
    super.key,
    required this.player,
    required this.backgroundColor,
    required this.showCommanderDamage,
    required this.onLifeChanged,
    required this.onPoisonChanged,
    this.inverted = false,
  });

  void _showPoisonModal(BuildContext context) {
    final matchCubit = context.read<MatchCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: matchCubit,
        child: BlocBuilder<MatchCubit, MatchState>(
          builder: (context, state) {
            final currentPlayer = state.players[player.id];
            if (currentPlayer == null) return const SizedBox.shrink();

            return RotatedBox(
              quarterTurns: inverted ? 2 : 0,
              child: CounterModal(
                title: AppStrings.poison,
                currentValue: currentPlayer.poisonCounters,
                onValueChanged: (amount) => onPoisonChanged(amount),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCommanderModal(BuildContext context) {
    final matchCubit = context.read<MatchCubit>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: matchCubit,
        child: RotatedBox(
          quarterTurns: inverted ? 2 : 0,
          child: CommanderDamageModal(targetPlayerId: player.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Verificamos se o jogador já perdeu (vida <= 0, etc)
    final bool isDead = player.isDead;

    return RotatedBox(
      quarterTurns: inverted ? 2 : 0,
      // 2. Bloqueia toques e escurece se estiver morto
      child: IgnorePointer(
        ignoring: isDead,
        child: Opacity(
          opacity: isDead ? 0.3 : 1.0,
          child: Container(
            color: backgroundColor,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onLifeChanged(1),
                        onLongPress: () => onLifeChanged(10),
                        behavior: HitTestBehavior.opaque,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onLifeChanged(-1),
                        onLongPress: () => onLifeChanged(-10),
                        behavior: HitTestBehavior.opaque,
                      ),
                    ),
                  ],
                ),
                IgnorePointer(
                  child: Center(
                    child: Text(
                      player.life.toString(),
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 12,
                  right: 12,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // 1. BOTÃO FIXO DE COMANDANTE (Para abrir o modal e adicionar dano)
                      if (showCommanderDamage)
                        _ClickableBadge(
                          icon: Icons.shield,
                          value: 0, // Pode ser 0 ou a soma total, como preferir
                          label:
                              "CMD", // Adicionei um label opcional se quiser identificar
                          onTap: () => _showCommanderModal(context),
                        ),

                      // 2. PÍLULAS DINÂMICAS (Mostram quem causou dano)
                      if (showCommanderDamage)
                        ...player.commanderDamageTaken.entries
                            .where((entry) => entry.value > 0)
                            .map(
                              (entry) => _CommanderDamagePill(
                                opponentId: entry.key,
                                value: entry.value,
                                onTap: () => _showCommanderModal(context),
                              ),
                            ),

                      // 3. BADGE DE VENENO
                      _ClickableBadge(
                        icon: Icons.science,
                        value: player.poisonCounters,
                        onTap: () => _showPoisonModal(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// O Badge antigo (usado para Veneno)
class _ClickableBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final String? label;
  final VoidCallback onTap;

  const _ClickableBadge({
    required this.icon,
    required this.value,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label ?? value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NOVO: Widget da Pílula de Comandante
class _CommanderDamagePill extends StatelessWidget {
  final String opponentId;
  final int value;
  final VoidCallback onTap;

  const _CommanderDamagePill({
    required this.opponentId,
    required this.value,
    required this.onTap,
  });

  Color _getOpponentColor(String id) {
    if (id == 'player_1') return Colors.blue.shade700;
    if (id == 'player_2') return Colors.red.shade700;
    if (id == 'player_3') return Colors.green.shade700;
    return Colors.deepPurple.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getOpponentColor(opponentId);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

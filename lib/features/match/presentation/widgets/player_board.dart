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
    return RotatedBox(
      quarterTurns: inverted ? 2 : 0,
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
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showCommanderDamage)
                    _ClickableBadge(
                      icon: Icons.shield,
                      value: player.commanderDamageTaken.values.fold(
                        0,
                        (sum, val) => sum + val,
                      ),
                      onTap: () => _showCommanderModal(context),
                    ),

                  if (showCommanderDamage) const SizedBox(width: 16),

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
    );
  }
}

class _ClickableBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final VoidCallback onTap;

  const _ClickableBadge({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

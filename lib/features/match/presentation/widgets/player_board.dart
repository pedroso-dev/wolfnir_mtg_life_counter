import 'package:flutter/material.dart';
import '../../domain/entities/player.dart';
import '../../../../core/constants/strings.dart';

class PlayerBoard extends StatelessWidget {
  final Player player;
  final Color backgroundColor;
  final bool inverted;
  final Function(int) onLifeChanged;
  final Function(int)? onCommanderDamageChanged;
  final Function(int)? onPoisonChanged;

  const PlayerBoard({
    super.key,
    required this.player,
    required this.backgroundColor,
    required this.onLifeChanged,
    this.onCommanderDamageChanged,
    this.onPoisonChanged,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    // If inverted (Player 2), we rotate the entire widget 180 degrees
    return RotatedBox(
      quarterTurns: inverted ? 2 : 0,
      child: Container(
        color: backgroundColor,
        child: Stack(
          children: [
            // Touch Areas for Life (+ and -)
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onLifeChanged(1),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onLifeChanged(-1),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
              ],
            ),

            // Visual Data (Life, Poison, Commander Damage)
            IgnorePointer(
              // Prevents text from blocking the touch areas
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.life.toString(),
                      style: const TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildExtraCounters(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MVP: Showing extra counters simply. We can add interactive buttons here later.
  Widget _buildExtraCounters() {
    final totalCommanderDamage = player.commanderDamageTaken.values.fold(
      0,
      (sum, val) => sum + val,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (totalCommanderDamage > 0)
          _CounterBadge(
            icon: Icons.shield,
            value: totalCommanderDamage,
            label: AppStrings.commanderDamage,
          ),
        const SizedBox(width: 16),
        if (player.poisonCounters > 0)
          _CounterBadge(
            icon: Icons.science,
            value: player.poisonCounters,
            label: AppStrings.poison,
          ),
      ],
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _CounterBadge({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
